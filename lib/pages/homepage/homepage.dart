import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // kIsWeb ke liye
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:chat_app/pages/homepage/callspage.dart';
import 'package:chat_app/pages/homepage/contactspage.dart';
import 'package:chat_app/pages/homepage/messagespage.dart';
import 'package:chat_app/pages/homepage/settings.dart';
import 'package:chat_app/services/zego_call_init.dart';
import 'package:chat_app/services/notification_service.dart'; // NAYA

class Homespage extends StatefulWidget {
  const Homespage({super.key});

  @override
  State<Homespage> createState() => _HomespageState();
}

class _HomespageState extends State<Homespage> {
  int currentIndex = 0;

  final List<Widget> pages = [
    const Messagespage(),
    const Callspage(),
    const Contactspage(),
    const Settingspage(),
  ];

  // ===== NAYA: message notifications ke liye =====
  StreamSubscription<QuerySnapshot>? _chatsSubscription;
  final Map<String, Timestamp?> _lastKnownMessageTimes = {};
  bool _isFirstSnapshot = true;

  @override
  void initState() {
    super.initState();
    _initPermissionsAndZego();
    _listenForNewMessages(); // NAYA
  }

  @override
  void dispose() {
    _chatsSubscription?.cancel(); // NAYA
    super.dispose();
  }

  // ============================================================
  // CRASH PROOF INITIALIZATION (CHROME + ANDROID SAFE)
  // ============================================================
  Future<void> _initPermissionsAndZego() async {
    try {
      // 1. Mobile (Android/iOS) par hi permission maango (Web par crash karta hai)
      if (!kIsWeb) {
        await [
          Permission.notification,
          Permission.camera,
          Permission.microphone,
        ].request();
      }

      // 2. Logged-in user ke sath Zego Invitation Service start karo
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final safeName =
            (currentUser.displayName != null &&
                currentUser.displayName!.trim().isNotEmpty)
            ? currentUser.displayName!.trim()
            : "User_${currentUser.uid.substring(0, 6)}";

        // Sirf mobile par Zego Invitation call init karein
        if (!kIsWeb) {
          await initZegoCallInvitationService(
            userId: currentUser.uid,
            userName: safeName,
          );

          // NAYA: local notification service bhi init karo
          await NotificationService().init();
        }

        print("✅ User Active: ${currentUser.uid}");
      }
    } catch (e) {
      print("⚠️ Init warning (safe ignore): $e");
    }
  }

  // ============================================================
  // NAYA: NEW MESSAGE LISTENER (foreground notifications)
  // ============================================================
  void _listenForNewMessages() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final currentUserId = currentUser.uid;

    _chatsSubscription = FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .snapshots()
        .listen((snapshot) {
          // Pehli snapshot par sirf state populate karo, notification mat dikhao
          // (warna app open karte hi purani saari chats ki notification aa jayegi)
          if (_isFirstSnapshot) {
            for (var doc in snapshot.docs) {
              final data = doc.data();
              _lastKnownMessageTimes[doc.id] =
                  data['lastMessageTime'] as Timestamp?;
            }
            _isFirstSnapshot = false;
            return;
          }

          for (var doc in snapshot.docs) {
            final data = doc.data();
            final chatId = doc.id;
            final lastSenderId = data['lastSenderId'] as String?;
            final lastMessage = data['lastMessage'] as String?;
            final lastMessageTime = data['lastMessageTime'] as Timestamp?;

            // Apna hi bheja hua message ho to skip
            if (lastSenderId == null || lastSenderId == currentUserId) {
              _lastKnownMessageTimes[chatId] = lastMessageTime;
              continue;
            }

            // Agar time nahi badla to ye purana hi message hai, skip
            final previousTime = _lastKnownMessageTimes[chatId];
            if (lastMessageTime == null || lastMessageTime == previousTime) {
              continue;
            }

            _lastKnownMessageTimes[chatId] = lastMessageTime;

            // Agar user isi chat ke andar hai to notification mat dikhao
            if (OpenChatTracker.currentOpenChatId == chatId) {
              continue;
            }

            // Sender ka naam Firestore users collection se lao
            FirebaseFirestore.instance
                .collection('users')
                .doc(lastSenderId)
                .get()
                .then((userDoc) {
                  final senderName = userDoc.exists
                      ? (userDoc.data()?['name'] ?? 'New message')
                      : 'New message';

                  NotificationService().showMessageNotification(
                    title: senderName,
                    body: lastMessage ?? '',
                    chatId: chatId,
                  );
                });
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.message), label: "Message"),
          BottomNavigationBarItem(icon: Icon(Icons.call), label: "Calls"),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: "Contacts",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}
