import 'package:flutter/material.dart';

import '../../models/property.dart';
import '../../services/firestore_service.dart';

class EditPropertyScreen extends StatefulWidget {
  final Property property;

  const EditPropertyScreen({
    super.key,
    required this.property,
  });

  @override
  State<EditPropertyScreen> createState() => _EditPropertyScreenState();
}

class _EditPropertyScreenState extends State<EditPropertyScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  final _formKey = GlobalKey<FormState>();

  late TextEditingController titleController;
  late TextEditingController locationController;
  late TextEditingController priceController;
  late TextEditingController bedroomController;
  late TextEditingController bathroomController;
  late TextEditingController descriptionController;
  late TextEditingController imageController;

  late String selectedCategory;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    titleController =
        TextEditingController(text: widget.property.title);

    locationController =
        TextEditingController(text: widget.property.location);

    priceController = TextEditingController(
      text: widget.property.price.toString(),
    );

    bedroomController = TextEditingController(
      text: widget.property.bedrooms.toString(),
    );

    bathroomController = TextEditingController(
      text: widget.property.bathrooms.toString(),
    );

    descriptionController =
        TextEditingController(text: widget.property.description);

    imageController = TextEditingController(
      text: widget.property.images.isNotEmpty
          ? widget.property.images.first
          : "",
    );
    selectedCategory = widget.property.category;
  }

  Future<void> updateProperty() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    await _firestoreService.updateProperty(
      widget.property.id,
      {
        "title": titleController.text.trim(),
        "location": locationController.text.trim(),
        "price": int.parse(priceController.text),
        "bedrooms": int.parse(bedroomController.text),
        "bathrooms": int.parse(bathroomController.text),
        "description": descriptionController.text.trim(),
        "imageUrl": imageController.text.trim(),
        "category": selectedCategory,
      },
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Property updated successfully."),
      ),
    );

    Navigator.pop(context);
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
  void dispose() {
    titleController.dispose();
    locationController.dispose();
    priceController.dispose();
    bedroomController.dispose();
    bathroomController.dispose();
    descriptionController.dispose();
    imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Property"),
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

              buildField(
                label: "Location",
                controller: locationController,
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

              buildField(
                label: "Image URL",
                controller: imageController,
              ),

              buildField(
                label: "Description",
                controller: descriptionController,
                maxLines: 4,
              ),

              const SizedBox(height: 15),

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
                  DropdownMenuItem(
                    value: "Hotel/Lodge",
                    child: Text("Hotel/Lodge"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                  });
                },
              ),

              const SizedBox(height: 25),

              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : updateProperty,
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                    "Update Property",
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