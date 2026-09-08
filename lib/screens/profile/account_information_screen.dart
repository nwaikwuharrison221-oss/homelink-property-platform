import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile_screen.dart';

class AccountInformationScreen extends StatelessWidget {
  const AccountInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text("No user is currently logged in."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Account Information"),
        centerTitle: true,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text("Unable to load account information."),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text("User information not found."),
            );
          }

          final data =
          snapshot.data!.data() as Map<String, dynamic>;

          final fullName = data['fullName'] ?? 'Not provided';
          final email = data['email'] ?? user.email ?? 'Not provided';
          final phone = data['phone'] ?? 'Not provided';
          final role = data['role'] ?? 'tenant';
          final isActive = data['isActive'] ?? false;
          final isVerified = data['isVerified'] ?? false;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 10),

              const CircleAvatar(
                radius: 45,
                child: Icon(
                  Icons.person,
                  size: 45,
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: Text(
                  fullName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 5),

              Center(
                child: Text(
                  role.toString().toUpperCase(),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              _infoCard(
                icon: Icons.person_outline,
                title: "Full Name",
                value: fullName,
              ),

              _infoCard(
                icon: Icons.email_outlined,
                title: "Email",
                value: email,
              ),

              _infoCard(
                icon: Icons.phone_outlined,
                title: "Phone Number",
                value: phone,
              ),

              _infoCard(
                icon: Icons.badge_outlined,
                title: "Account Role",
                value: role.toString(),
              ),

              _infoCard(
                icon: Icons.check_circle_outline,
                title: "Account Status",
                value: isActive ? "Active" : "Inactive",
              ),

              _infoCard(
                icon: Icons.verified_user_outlined,
                title: "Verification Status",
                value: isVerified ? "Verified" : "Not Verified",
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final updated = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProfileScreen(
                          fullName: fullName.toString(),
                          phone: phone.toString(),
                        ),
                      ),
                    );

                    if (updated == true && context.mounted) {
                      Navigator.pop(context);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AccountInformationScreen(),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text("Edit Profile"),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}