import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/firestore_service.dart';
import '../../models/property.dart';
import 'property_details_screen.dart';
import '../../utils/price_formatter.dart';

class FavoritesScreen extends StatelessWidget {
  FavoritesScreen({super.key});

  final FirestoreService firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text("Please login first."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Favorites"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getFavorites(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text("Something went wrong"),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No favorite properties yet."),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final favorite = snapshot.data!.docs[index];

              return FutureBuilder<DocumentSnapshot>(
                future: firestoreService.getPropertyById(
                  favorite["propertyId"],
                ),
                builder: (context, propertySnapshot) {
                  if (!propertySnapshot.hasData) {
                    return const ListTile(
                      title: Text("Loading..."),
                    );
                  }

                  if (!propertySnapshot.data!.exists) {
                    return const SizedBox();
                  }

                  final data =
                  propertySnapshot.data!.data() as Map<String, dynamic>;

                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        data["imageUrl"] ?? "",
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 70,
                            height: 70,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.home),
                          );
                        },
                      ),
                    ),
                    title: Text(
                      data["title"] ?? "",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),

                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(data["location"] ?? ""),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        Text(
                          PriceFormatter.format(data["price"]),
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Row(
                          children: [
                            const Icon(
                              Icons.bed,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text("${data["bedrooms"]} Beds"),

                            const SizedBox(width: 16),

                            const Icon(
                              Icons.bathtub,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text("${data["bathrooms"]} Baths"),
                          ],
                        ),
                      ],
                    ),

                    trailing: IconButton(
                      icon: const Icon(
                        Icons.favorite,
                        color: Colors.red,
                      ),
                      onPressed: () async {
                        await firestoreService.removeFromFavorites(
                          userId: user.uid,
                          propertyId: favorite["propertyId"],
                        );

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Removed from favorites"),
                            ),
                          );
                        }
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PropertyDetailsScreen(
                            property: Property.fromFirestore(
                              propertySnapshot.data!.id,
                              data,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}