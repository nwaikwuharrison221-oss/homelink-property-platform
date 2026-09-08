class Property {
  final String id;
  final String title;
  final int price;
  final String location;
  final int bedrooms;
  final int bathrooms;
  final List<String> images;
  final String ownerId;
  final String description;
  final String category;
  final bool available;

  const Property({
    required this.id,
    required this.title,
    required this.price,
    required this.location,
    required this.bedrooms,
    required this.bathrooms,
    required this.images,
    required this.ownerId,
    required this.description,
    required this.category,
    this.available = true,
  });

  factory Property.fromFirestore(
      String id,
      Map<String, dynamic> data,
      ) {
    return Property(
      id: id,
      title: data['title'] ?? '',
      price: data['price'] ?? 0,
      location: data['location'] ?? '',
      category: data['category'] ?? '',
      bedrooms: data['bedrooms'] ?? 0,
      bathrooms: data['bathrooms'] ?? 0,
      images: (data['images'] is List &&
          (data['images'] as List).isNotEmpty)
          ? List<String>.from(data['images'])
          : ((data['imageUrl'] ?? '').toString().isNotEmpty
          ? [data['imageUrl'].toString()]
          : []),
      description: data['description'] ?? '',
      ownerId: data["ownerId"] ?? "",
      available: data['available'] ?? true,
    );
  }
}