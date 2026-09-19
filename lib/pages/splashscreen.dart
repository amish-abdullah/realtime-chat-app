import 'dart:async';

import 'package:chat_app/pages/homepage/homepage.dart';
import 'package:chat_app/pages/onboardingpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/zego_call_init.dart'; // path apne project ke mutabiq adjust karo

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkUser();
  }

  Future<void> checkUser() async {
    await Future.delayed(const Duration(seconds: 3));

    User? user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    if (user != null) {
      // ===== NAYA: user already logged in, Zego call service init karo =====
      await initZegoCallInvitationService(
        userId: user.uid,
        userName: user.displayName?.trim().isNotEmpty == true
            ? user.displayName!.trim()
            : "User_${user.uid.substring(0, 6)}",
      );

      if (!mounted) return;

      // User already logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Homespage()),
      );
    } else {
      // User not logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Onboardingpage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat, size: 100, color: Colors.white),

            SizedBox(height: 20),

            Text(
              "Chat App",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
