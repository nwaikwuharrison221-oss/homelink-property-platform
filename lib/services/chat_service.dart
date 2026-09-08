import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get chats => _firestore.collection('chats');

  /// Returns an existing chat or creates a new one.
  Future<String> createOrGetChat({
    required String landlordId,
    required String tenantId,
    required String propertyId,
    required String propertyTitle,
  }) async {
    final query = await chats
        .where('landlordId', isEqualTo: landlordId)
        .where('tenantId', isEqualTo: tenantId)
        .where('propertyId', isEqualTo: propertyId)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return query.docs.first.id;
    }

    final doc = await chats.add({
      'landlordId': landlordId,
      'tenantId': tenantId,
      'propertyId': propertyId,
      'propertyTitle': propertyTitle,
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'participants': [landlordId, tenantId],
    });

    return doc.id;
  }

  /// Send a message
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String message,
  }) async {
    await chats.doc(chatId).collection('messages').add({
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    await chats.doc(chatId).update({
      'lastMessage': message,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }

  /// Listen for messages
  Stream<QuerySnapshot> getMessages(String chatId) {
    return chats
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots();
  }

  /// Listen for a user's conversations
  Stream<QuerySnapshot> getChats(String userId) {
    return chats
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }
}