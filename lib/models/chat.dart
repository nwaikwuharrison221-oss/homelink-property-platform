class Chat {
  final String id;
  final String landlordId;
  final String tenantId;
  final String propertyId;
  final String propertyTitle;
  final String lastMessage;

  Chat({
    required this.id,
    required this.landlordId,
    required this.tenantId,
    required this.propertyId,
    required this.propertyTitle,
    required this.lastMessage,
  });

  factory Chat.fromFirestore(
      String id,
      Map<String, dynamic> data,
      ) {
    return Chat(
      id: id,
      landlordId: data['landlordId'] ?? '',
      tenantId: data['tenantId'] ?? '',
      propertyId: data['propertyId'] ?? '',
      propertyTitle: data['propertyTitle'] ?? '',
      lastMessage: data['lastMessage'] ?? '',
    );
  }
}