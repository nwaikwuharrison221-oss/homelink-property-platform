import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class AddPropertyScreen extends StatefulWidget {

  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {

  final FirestoreService _firestoreService = FirestoreService();

  double? latitude;
  double? longitude;
  double? locationAccuracy;

  bool isGettingLocation = false;

  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();

  final locationController = TextEditingController();
  final priceController = TextEditingController();
  final bedroomController = TextEditingController();
  final bathroomController = TextEditingController();
  final descriptionController = TextEditingController();

  String selectedCategory = "Apartment";

  bool isLoading = false;

  XFile? selectedImage;

  final ImagePicker picker = ImagePicker();

  Future<void> pickImage(ImageSource source) async {
    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        selectedImage = image;
      });
    }
  }

  Future<void> getCurrentLocation() async {
    setState(() {
      isGettingLocation = true;
    });

    try {
      bool serviceEnabled =
      await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Location services are disabled. Please enable GPS.",
            ),
          ),
        );

        return;
      }

      LocationPermission permission =
      await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission =
        await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Location permission was denied."),
          ),
        );

        return;
      }

      if (permission ==
          LocationPermission.deniedForever) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Location permission is permanently denied. "
                  "Please enable it from device settings.",
            ),
          ),
        );

        return;
      }

     final position =
await Geolocator.getCurrentPosition(
  locationSettings: const LocationSettings(
    accuracy: LocationAccuracy.high,
  ),
);

String capturedAddress =
    "${position.latitude.toStringAsFixed(6)}, "
    "${position.longitude.toStringAsFixed(6)}";

try {
  final placemarks = await Geocoding().placemarkFromCoordinates(
    position.latitude,
    position.longitude,
  );

  if (placemarks.isNotEmpty) {
    final place = placemarks.first;

    final addressParts = <String?>[
      place.street,
      place.subLocality,
      place.locality,
      place.administrativeArea,
      place.country,
    ]
        .whereType<String>()
        .where((part) => part.trim().isNotEmpty)
        .toSet()
        .toList();

    if (addressParts.isNotEmpty) {
      capturedAddress = addressParts.join(", ");
    }
  }
} catch (_) {
  // Coordinates remain available if address lookup fails.
}

if (!mounted) return;

setState(() {
  latitude = position.latitude;
  longitude = position.longitude;
  locationAccuracy = position.accuracy;
  locationController.text = capturedAddress;
});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Current property location captured.",
          ),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint("SAVE PROPERTY ERROR: $e");
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Unable to capture location: $e",
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isGettingLocation = false;
        });
      }
    }
  }

  Future<void> saveProperty() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload a property photo.")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser!;

      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.uid)
          .get();

      final userData = userDoc.data()!;

      final storageRef = FirebaseStorage.instance
          .ref()
          .child("property_images")
          .child("${DateTime.now().millisecondsSinceEpoch}.jpg");

      final imageBytes = await selectedImage!.readAsBytes();

      await storageRef.putData(
        imageBytes,
        SettableMetadata(
          contentType: selectedImage!.mimeType ?? "image/jpeg",
        ),
      );

      final imageUrl = await storageRef.getDownloadURL();

      await _firestoreService.addProperty({
        "title": titleController.text.trim(),
        "category": selectedCategory,

        "location": locationController.text.trim(),
        "latitude": latitude,
        "longitude": longitude,
        "locationAccuracy": locationAccuracy,
        "locationCapturedAt": latitude != null
            ? FieldValue.serverTimestamp()
            : null,
        "locationSource": latitude != null ? "gps" : "manual",

        "price": int.parse(priceController.text),
        "bedrooms": int.parse(bedroomController.text),
        "bathrooms": int.parse(bathroomController.text),
        "description": descriptionController.text.trim(),
        "imageUrl": imageUrl,
        "images": [imageUrl],
        "available": true,
        "ownerId": currentUser.uid,
        "ownerName": userData["fullName"],
        "ownerEmail": userData["email"],
        "createdAt": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget buildField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
  }) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        maxLines: maxLines,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "$label is required";
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Add Property"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: ListView(

            children: [

              buildField(
                label: "Property Title",
                controller: titleController,
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: TextFormField(
                  controller: locationController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Location is required";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "Location",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: isGettingLocation
                        ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    )
                        : IconButton(
                      tooltip: "Capture current property location",
                      icon: const Icon(Icons.my_location),
                      onPressed: getCurrentLocation,
                    ),
                  ),
                ),
              ),

              if (latitude != null && longitude != null)
                Padding(
                  padding: const EdgeInsets.only(
                    left: 5,
                    bottom: 15,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 18,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          "Property GPS location captured"
                              "${locationAccuracy != null ? " • Accuracy: ${locationAccuracy!.toStringAsFixed(0)} m" : ""}",
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              buildField(
                label: "Price",
                controller: priceController,
                keyboard: TextInputType.number,
              ),

              buildField(
                label: "Bedrooms",
                controller: bedroomController,
                keyboard: TextInputType.number,
              ),

              buildField(
                label: "Bathrooms",
                controller: bathroomController,
                keyboard: TextInputType.number,
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Property Photo",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  if (selectedImage != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: FutureBuilder<Uint8List>(
                        future: selectedImage!.readAsBytes(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox(
                              height: 200,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          return Image.memory(
                            snapshot.data!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 10),

                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => pickImage(ImageSource.gallery),
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(12),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.photo_library_outlined,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "Choose property photo",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        IconButton(
                          tooltip: "Take Photo",
                          onPressed: () => pickImage(ImageSource.camera),
                          icon: const Icon(
                            Icons.camera_alt,
                            size: 26,
                          ),
                        ),

                        const SizedBox(width: 6),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),

              buildField(
                label: "Description",
                controller: descriptionController,
                maxLines: 4,
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                decoration: const InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: "Apartment",
                    child: Text("Apartment"),
                  ),
                  DropdownMenuItem(
                    value: "Duplex",
                    child: Text("Duplex"),
                  ),
                  DropdownMenuItem(
                    value: "Self Contain",
                    child: Text("Self Contain"),
                  ),
                  DropdownMenuItem(
                    value: "Shop",
                    child: Text("Shop"),
                  ),
                  DropdownMenuItem(
                    value: "Office",
                    child: Text("Office"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                  });
                },
              ),

              SizedBox(
                height: 55,
                child: ElevatedButton(

                  onPressed: isLoading ? null : saveProperty,

                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                    "Save Property",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}