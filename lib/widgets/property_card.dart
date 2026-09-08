import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/property.dart';
import '../screens/home/property_details_screen.dart';
import '../services/firestore_service.dart';
import '../utils/price_formatter.dart';

class PropertyCard extends StatefulWidget {
  final Property property;

  const PropertyCard({
    super.key,
    required this.property,
  });

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  final FirestoreService firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PropertyDetailsScreen(
              property: widget.property,
            ),
          ),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
              child: Image.network(
                widget.property.images.isNotEmpty
                    ? widget.property.images.first
                    : "",
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 180,
                    width: double.infinity,
                    color: Colors.grey.shade300,
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 50,
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      Text(
                        PriceFormatter.format(widget.property.price),
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      if (user != null)
                        StreamBuilder<bool>(
                          stream: firestoreService.isFavorite(
                            userId: user.uid,
                            propertyId: widget.property.id,
                          ),
                          builder: (context, snapshot) {
                            final isFavorite = snapshot.data ?? false;

                            return IconButton(
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.red,
                              ),
                              onPressed: () async {
                                if (isFavorite) {
                                  await firestoreService.removeFromFavorites(
                                    userId: user.uid,
                                    propertyId: widget.property.id,
                                  );
                                } else {
                                  await firestoreService.addToFavorites(
                                    userId: user.uid,
                                    propertyId: widget.property.id,
                                  );
                                }
                              },
                            );
                          },
                        ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Text(
                    widget.property.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.grey,
                        size: 18,
                      ),
                      const SizedBox(width: 5),
                      Text(widget.property.location),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const Icon(Icons.bed),
                      SizedBox(width: 5),
                      Text("${widget.property.bedrooms} Beds"),
                      SizedBox(width: 20),
                      const Icon(Icons.bathtub),
                      SizedBox(width: 5),
                      Text("${widget.property.bathrooms} Baths"),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}