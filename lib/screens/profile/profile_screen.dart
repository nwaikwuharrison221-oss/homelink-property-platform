import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../property/my_properties_screen.dart';
import '../home/favorites_screen.dart';
import '../messages_screen.dart';
import 'settings_screen.dart';
import '../../widgets/live_date_time.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _formatRole(String role) {
    if (role.isEmpty) return "Tenant";

    return role
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : "${word[0].toUpperCase()}${word.substring(1).toLowerCase()}",
        )
        .join(' ');
  }

  String _getInitials(String name) {
    final words = name.trim().split(RegExp(r'\s+'));

    if (words.isEmpty || words.first.isEmpty) {
      return "H";
    }

    if (words.length == 1) {
      return words.first[0].toUpperCase();
    }

    return "${words.first[0]}${words.last[0]}".toUpperCase();
  }

  Widget _informationTile({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(
        title,
        style: const TextStyle(color: Colors.grey, fontSize: 13),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: valueColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Please log in to view your profile.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text("Unable to load profile information."),
            );
          }

          final data = snapshot.data?.data() ?? {};

          final firestoreName = data['fullName']?.toString().trim() ?? "";

          final displayName = firestoreName.isNotEmpty
              ? firestoreName
              : (user.displayName?.trim().isNotEmpty == true
                    ? user.displayName!
                    : "HomeLink User");

          final email = data['email']?.toString().trim().isNotEmpty == true
              ? data['email'].toString()
              : (user.email ?? "No email available");

          final phone = data['phone']?.toString().trim().isNotEmpty == true
              ? data['phone'].toString()
              : "No phone number";

          final role =
              data['role']?.toString().trim().toLowerCase() ?? "tenant";

          final isVerified = user.emailVerified || data['isVerified'] == true;

          final isActive = data['isActive'] != false;

          final canManageProperties = [
            'landlord',
            'agent',
            'admin',
          ].contains(role);

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blue,
                      child: Text(
                        _getInitials(displayName),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    Text(
                      displayName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      email,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontSize: 15),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _formatRole(role),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              const LiveDateTime(),

              const SizedBox(height: 20),

              Card(
                child: Column(
                  children: [
                    _informationTile(
                      icon: Icons.phone,
                      title: "Phone number",
                      value: phone,
                    ),
                    const Divider(height: 1),
                    _informationTile(
                      icon: isVerified ? Icons.verified : Icons.warning_amber,
                      title: "Email verification",
                      value: isVerified ? "Verified" : "Not verified",
                      valueColor: isVerified ? Colors.green : Colors.orange,
                    ),
                    const Divider(height: 1),
                    _informationTile(
                      icon: isActive ? Icons.check_circle : Icons.block,
                      title: "Account status",
                      value: isActive ? "Active" : "Inactive",
                      valueColor: isActive ? Colors.green : Colors.red,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              if (canManageProperties)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.home_work, color: Colors.blue),
                    title: const Text("My Properties"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
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
                  leading: const Icon(Icons.favorite, color: Colors.red),
                  title: const Text("Favorites"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => FavoritesScreen()),
                    );
                  },
                ),
              ),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.message, color: Colors.blue),
                  title: const Text("Messages"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => MessagesScreen()),
                    );
                  },
                ),
              ),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.settings, color: Colors.grey),
                  title: const Text("Settings"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
