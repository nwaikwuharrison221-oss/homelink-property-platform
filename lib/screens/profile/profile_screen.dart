import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../property/my_properties_screen.dart';
import '../home/favorites_screen.dart';
import '../messages_screen.dart';
import 'settings_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 20),

          const CircleAvatar(
            radius: 50,
            child: Icon(
              Icons.person,
              size: 50,
            ),
          ),

          const SizedBox(height: 15),

          Center(
            child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                final data = snapshot.data?.data();
                final firestoreName =
                data?['fullName']?.toString().trim();

                final displayName =
                firestoreName != null && firestoreName.isNotEmpty
                    ? firestoreName
                    : (user.displayName ?? "HomeLink User");

                return Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 5),

          Center(
            child: Text(
              user.email ?? "No Email",
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ),

          const SizedBox(height: 30),

          Card(
            child: ListTile(
              leading: const Icon(Icons.home_work),
              title: const Text("My Properties"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MyPropertiesScreen(),
                  ),
                );
              },
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text("Favorites"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FavoritesScreen(),
                  ),
                );
              },
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.message),
              title: const Text("Messages"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MessagesScreen(),
                  ),
                );
              },
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 30),

          ElevatedButton.icon(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}