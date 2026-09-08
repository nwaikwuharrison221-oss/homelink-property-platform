import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'account_information_screen.dart';
import 'privacy_security_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  bool isLoadingNotifications = true;

  @override
  void initState() {
    super.initState();
    loadNotificationPreference();
  }

  Future<void> loadNotificationPreference() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        isLoadingNotifications = false;
      });
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final data = doc.data();

    if (!mounted) return;

    setState(() {
      notificationsEnabled =
          data?['notificationsEnabled'] ?? true;

      isLoadingNotifications = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          const Text(
            "Account",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Card(
            child: ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text("Account Information"),
              subtitle: Text(user?.email ?? "No email"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AccountInformationScreen(),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "Preferences",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.notifications_outlined),
              title: const Text("Notifications"),
              subtitle: const Text(
                "Receive HomeLink notifications",
              ),
              value: notificationsEnabled,
              onChanged: isLoadingNotifications
                  ? null
                  : (value) async {
                setState(() {
                  notificationsEnabled = value;
                });

                final user = FirebaseAuth.instance.currentUser;

                if (user == null) return;

                try {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .update({
                    'notificationsEnabled': value,
                  });
                } catch (e) {
                  if (!context.mounted) return;

                  setState(() {
                    notificationsEnabled = !value;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Unable to update notification preference",
                      ),
                    ),
                  );
                }
              },
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text("Privacy & Security"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PrivacySecurityScreen(),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "About",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text("About HomeLink"),
              subtitle: const Text("Version 1.1"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: "HomeLink",
                  applicationVersion: "1.1",
                  applicationLegalese:
                  "Property discovery, rental and booking platform.",
                );
              },
            ),
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(
                Icons.logout,
                color: Colors.red,
              ),
              label: const Text(
                "Logout",
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
              onPressed: () async {
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Logout"),
                      content: const Text(
                        "Are you sure you want to logout?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                          child: const Text(
                            "Logout",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    );
                  },
                );

                if (shouldLogout != true) return;

                await FirebaseAuth.instance.signOut();

                if (context.mounted) {
                  Navigator.of(context).popUntil(
                        (route) => route.isFirst,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}