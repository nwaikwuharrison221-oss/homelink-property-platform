import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/property.dart';
import '../../services/firestore_service.dart';
import '../home/property_details_screen.dart';
import 'edit_property_screen.dart';
import '../../utils/price_formatter.dart';

class MyPropertiesScreen extends StatefulWidget {
  const MyPropertiesScreen({super.key});

  @override
  State<MyPropertiesScreen> createState() => _MyPropertiesScreenState();
}

class _MyPropertiesScreenState extends State<MyPropertiesScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  Future<void> _deleteProperty(Property property) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Property"),
        content: Text(
          "Are you sure you want to delete '${property.title}'?\n\n"
              "This action cannot be undone.",
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
      await _firestoreService.deleteProperty(property.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Property deleted successfully."),
        ),
      );
    }
  }

  Future<void> _updateAvailability(
      Property property,
      bool available,
      ) async {
    try {
      await FirebaseFirestore.instance
          .collection('properties')
          .doc(property.id)
          .update({
        'available': available,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            available
                ? "Property marked as available."
                : "Property marked as rented.",
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Unable to update property: $e"),
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Properties"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getMyProperties(currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "You haven't added any properties yet.",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final properties = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: properties.length,
            itemBuilder: (context, index) {
              final doc = properties[index];
              final data = doc.data() as Map<String, dynamic>;

              final property = Property.fromFirestore(doc.id, data);

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (property.images.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child:Image.network(
                            property.images.isNotEmpty
                                ? property.images.first
                                : "",
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) {
                              return Container(
                                height: 180,
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.home,
                                  size: 60,
                                ),
                              );
                            },
                          ),
                        ),

                      const SizedBox(height: 12),

                      Text(
                        property.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(property.location),

                      const SizedBox(height: 6),

                      Text(
                        PriceFormatter.format(property.price),
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          property.available ? "Available" : "Rented",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: property.available
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                        subtitle: Text(
                          property.available
                              ? "This property is visible to customers."
                              : "This property is hidden from customers.",
                        ),
                        value: property.available,
                        secondary: Icon(
                          property.available
                              ? Icons.check_circle
                              : Icons.block,
                          color: property.available
                              ? Colors.green
                              : Colors.orange,
                        ),
                        onChanged: (value) {
                          _updateAvailability(property, value);
                        },
                      ),

                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          OutlinedButton.icon(
                            icon: const Icon(Icons.visibility),
                            label: const Text("View"),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PropertyDetailsScreen(
                                    property: property,
                                  ),
                                ),
                              );
                            },
                          ),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.edit),
                            label: const Text("Edit"),
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
                          ),
                          OutlinedButton.icon(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            label: const Text(
                              "Delete",
                              style: TextStyle(color: Colors.red),
                            ),
                            onPressed: () => _deleteProperty(property),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}