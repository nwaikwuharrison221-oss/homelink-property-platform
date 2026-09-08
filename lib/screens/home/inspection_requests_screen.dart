import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/firestore_service.dart';

class InspectionRequestsScreen extends StatelessWidget {
  InspectionRequestsScreen({super.key});

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
        title: const Text("Inspection Requests"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getInspectionRequests(user.uid),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No inspection requests yet."),
            );
          }

          // Keep the rest of your ListView.builder unchanged.

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final request = snapshot.data!.docs[index];

              return Card(
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Icon(
                            Icons.calendar_month,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(request["propertyTitle"]),
                    subtitle: Text(
                      "Status: ${request["status"]}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: request["status"] == "Approved"
                            ? Colors.green
                            : request["status"] == "Rejected"
                            ? Colors.red
                            : Colors.orange,
                      ),
                    ),
                      ),

                      const SizedBox(height: 10),

                      if (request["status"] == "Pending")
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  await firestoreService.updateInspectionStatus(
                                    requestId: request.id,
                                    status: "Approved",
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                child: const Text("Approve"),
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  await firestoreService.updateInspectionStatus(
                                    requestId: request.id,
                                    status: "Rejected",
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text("Reject"),
                              ),
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