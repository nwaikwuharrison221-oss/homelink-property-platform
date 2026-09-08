import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home/home_screen.dart';
import '../main.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends State<EmailVerificationScreen> {

  bool isSending = false;
  bool isChecking = false;

  Future<void> resendEmail() async {
    setState(() => isSending = true);

    await FirebaseAuth.instance.currentUser!
        .sendEmailVerification();

    setState(() => isSending = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Verification email sent."),
      ),
    );
  }

  Future<void> checkVerification() async {
    setState(() => isChecking = true);

    await FirebaseAuth.instance.currentUser!.reload();

    final user = FirebaseAuth.instance.currentUser;

    if (user != null && user.emailVerified) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email is not verified yet."),
        ),
      );
    }

    setState(() => isChecking = false);
  }

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? "";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify Email"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Icon(
              Icons.mark_email_read,
              size: 90,
              color: Colors.blue,
            ),

            const SizedBox(height: 25),

            const Text(
              "Verify your email",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Text(
              "We've sent a verification email to\n$email",
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 35),

            ElevatedButton(
              onPressed: isSending ? null : resendEmail,
              child: isSending
                  ? const CircularProgressIndicator()
                  : const Text("Resend Verification Email"),
            ),

            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: isChecking ? null : checkVerification,
              child: isChecking
                  ? const CircularProgressIndicator()
                  : const Text("I've Verified"),
            ),

            const SizedBox(height: 15),

            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WelcomeScreen(),
                  ),
                      (route) => false,
                );
              },
              child: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}