import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy & Security"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text("Email Verification"),
              subtitle: Text(
                user?.emailVerified == true
                    ? "Your email is verified"
                    : "Your email is not verified",
              ),
              trailing: Icon(
                user?.emailVerified == true
                    ? Icons.verified
                    : Icons.warning_amber,
              ),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.password),
              title: const Text("Change Password"),
              subtitle: const Text(
                "Send a password reset link to your email",
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () async {
                final email = user?.email;

                if (email == null || email.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("No email address found"),
                    ),
                  );
                  return;
                }

                try {
                  await FirebaseAuth.instance.sendPasswordResetEmail(
                    email: email,
                  );

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Password reset link sent to $email",
                      ),
                    ),
                  );
                } on FirebaseAuthException catch (e) {
                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        e.message ?? "Unable to send reset email",
                      ),
                    ),
                  );
                }
              },
            ),
          ),

          const SizedBox(height: 20),

          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.shield_outlined),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "HomeLink will never ask you to share your password, "
                          "PIN, OTP, card security code, or other private "
                          "authentication details with another user.",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}