import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/chat_service.dart';
import 'home/chat_screen.dart';

class MessagesScreen extends StatelessWidget {
  MessagesScreen({super.key});

  final ChatService chatService = ChatService();

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
        title: const Text("Messages"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: chatService.getChats(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            debugPrint("MESSAGES FIRESTORE ERROR: ${snapshot.error}");

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Firestore Error:\n\n${snapshot.error}",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No conversations yet."),
            );
          }

          final chats = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final data =
              chats[index].data() as Map<String, dynamic>;

              final receiverId =
              data["landlordId"] == user.uid
                  ? data["tenantId"]
                  : data["landlordId"];

              return ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Text(data["propertyTitle"] ?? ""),
                subtitle: Text(data["lastMessage"] ?? ""),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        chatId: chats[index].id,
                        receiverId: receiverId,
                        title: data["propertyTitle"] ?? "Chat",
                      ),
                    ),
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