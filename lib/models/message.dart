class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final bool isRead;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.isRead,
  });

  factory Message.fromFirestore(
      String id,
      Map<String, dynamic> data,
      ) {
    return Message(
      id: id,
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      message: data['message'] ?? '',
      isRead: data['isRead'] ?? false,
    );
  }
}