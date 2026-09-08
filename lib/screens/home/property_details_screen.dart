import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../property/edit_property_screen.dart';
import '../../models/property.dart';
import '../../services/firestore_service.dart';
import '../../services/chat_service.dart';
import 'chat_screen.dart';
import '../../utils/price_formatter.dart';
import '../../utils/price_in_words.dart';

class PropertyDetailsScreen extends StatelessWidget {
  final Property property;

  const PropertyDetailsScreen({
    super.key,
    required this.property,
  });

  @override
  Widget build(BuildContext context) {

    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final user = FirebaseAuth.instance.currentUser;
    final firestoreService = FirestoreService();
    final chatService = ChatService();
    final bool isOwner = currentUserId == property.ownerId;

    debugPrint("Current User ID: $currentUserId");
    debugPrint("Property Owner ID: ${property.ownerId}");
    debugPrint("Is Owner: $isOwner");

    return Scaffold(
      appBar: AppBar(
        title: const Text("Property Details"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
              child: Image.network(
                property.images.isNotEmpty
                    ? property.images.first
                    : "",
                width: double.infinity,
                height: 280,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 280,
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 60,
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    property.title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      PriceFormatter.format(property.price),
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    PriceInWords.convert(property.price),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(property.location),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [

                      Expanded(
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.bed,
                                  color: Colors.blue,
                                  size: 35,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "${property.bedrooms}",
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text("Bedrooms"),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 15),

                      Expanded(
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.bathtub,
                                  color: Colors.blue,
                                  size: 35,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "${property.bathrooms}",
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text("Bathrooms"),
                              ],
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Description",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            property.description,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 15),

                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.red.shade50,
                        child: IconButton(
                          onPressed: () async {
                            await firestoreService.addToFavorites(
                              userId: currentUserId,
                              propertyId: property.id,
                            );

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Added to favorites ❤️"),
                                ),
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.favorite_border,
                            color: Colors.red,
                          ),
                        ),
                      ),

                    ],
                  ),

                  const SizedBox(height: 35),

                  if (isOwner) ...[

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditPropertyScreen(
                                property: property,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text("Edit Property"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.delete),
                        label: const Text("Delete Property"),
                        onPressed: () async {

                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Delete Property"),
                              content: const Text(
                                "Are you sure you want to delete this property?",
                              ),
                              actions: [

                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text("Cancel"),
                                ),

                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text("Delete"),
                                ),

                              ],
                            ),
                          );

                          if (confirm == true) {

                            await FirebaseFirestore.instance
                                .collection("properties")
                                .doc(property.id)
                                .delete();

                            if (context.mounted) {
                              Navigator.pop(context);
                            }

                          }

                        },
                      ),
                    ),

                  ] else ...[

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await firestoreService.bookInspection(
                            propertyId: property.id,
                            tenantId: currentUserId,
                            landlordId: property.ownerId,
                            propertyTitle: property.title,
                          );

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Inspection request sent successfully!"),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.calendar_month),
                        label: const Text(
                          "Book Inspection",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          elevation: 5,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          if (user == null) return;

                          final chatId = await chatService.createOrGetChat(
                            landlordId: property.ownerId,
                            tenantId: user.uid,
                            propertyId: property.id,
                            propertyTitle: property.title,
                          );

                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  chatId: chatId,
                                  receiverId: property.ownerId,
                                  title: property.title,
                                ),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.phone),
                        label: const Text(
                          "Contact Owner",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          side: const BorderSide(
                            color: Colors.blue,
                            width: 2,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),

                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}