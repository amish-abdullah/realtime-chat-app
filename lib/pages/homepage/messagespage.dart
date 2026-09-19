import 'package:chat_app/pages/chatpage/chatpage.dart';
import 'package:chat_app/pages/homepage/new_chatpage.dart';
import 'package:chat_app/pages/profilepage.dart';
import 'package:chat_app/services/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../widgets/user_avatar.dart';

class Messagespage extends StatelessWidget {
  const Messagespage({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatService chatService = ChatService();
    final currentUser = FirebaseAuth.instance.currentUser;

    // Agar auth state abhi ready nahi hui to loading dikhayein
    if (currentUser == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    final currentUserId = currentUser.uid;

    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const Newchatpage()),
          );
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.add_comment_outlined, color: Colors.white),
      ),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            // Search Screen
          },
          icon: const Icon(Icons.search, color: Colors.white),
        ),
        centerTitle: true,
        title: const Text(
          "Home",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
              child: UserAvatar(
                userId: FirebaseAuth.instance.currentUser!.uid,
                fallbackName:
                    FirebaseAuth.instance.currentUser?.displayName ?? "U",
                radius: 15,
              ),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // ===== STATUS / STORIES ROW =====
          SizedBox(
            height: 90,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildStatusItem("My status", null, isMe: true),
                _buildStatusItem("user1", Colors.orange),
                _buildStatusItem("user2", Colors.pink),
                _buildStatusItem("user3", Colors.blue),
                _buildStatusItem("user4", Colors.grey),
              ],
            ),
          ),

          // ===== WHITE ROUNDED CARD (CHAT LIST) =====
          // ClipRRect + Material yahan use kiya hai (Container(decoration:...) ki
          // jagah), warna ListTile ka ripple/splash effect chup jata hai aur
          // "ListTile background color or ink splashes may be invisible" warning
          // aati hai.
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
              child: Material(
                color: Colors.white,
                child: StreamBuilder<QuerySnapshot>(
                  stream: chatService.getUserChats(currentUserId),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final chatDocs = snapshot.data!.docs;

                    if (chatDocs.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Text(
                            "press the below button to start new chats",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 15),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 12),
                      itemCount: chatDocs.length,
                      itemBuilder: (context, index) {
                        final chat = chatDocs[index];
                        final participants = List<String>.from(
                          chat['participants'],
                        );
                        final otherUserId = participants.firstWhere(
                          (id) => id != currentUserId,
                        );

                        final chatData = chat.data() as Map<String, dynamic>;
                        final unreadMap =
                            chatData['unreadCount'] as Map<String, dynamic>?;
                        final unreadCount = unreadMap?[currentUserId] ?? 0;
                        final lastMessageTime =
                            chatData['lastMessageTime'] as Timestamp?;

                        return FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .doc(otherUserId)
                              .get(),
                          builder: (context, userSnapshot) {
                            if (!userSnapshot.hasData) {
                              return const ListTile(title: Text("Loading..."));
                            }

                            final userData =
                                userSnapshot.data!.data()
                                    as Map<String, dynamic>?;
                            final name = userData?['name'] ?? 'Unknown';

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 6,
                              ),
                              leading: CircleAvatar(
                                radius: 26,
                                backgroundColor: Colors.grey.shade300,
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                chatData['lastMessage'] ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                              trailing: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    _formatTime(lastMessageTime),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  if (unreadCount > 0)
                                    CircleAvatar(
                                      radius: 10,
                                      backgroundColor: Colors.redAccent,
                                      child: Text(
                                        '$unreadCount',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => Chatpage(
                                      receiverId: otherUserId,
                                      receiverName: name,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== Status circle widget (top row) =====
  Widget _buildStatusItem(String name, Color? color, {bool isMe = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 14),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isMe ? Colors.grey : (color ?? Colors.grey),
                width: 2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: CircleAvatar(
                backgroundColor: Colors.grey.shade700,
                child: isMe
                    ? const Icon(Icons.add, color: Colors.white, size: 20)
                    : const Icon(Icons.person, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(name, style: const TextStyle(color: Colors.white, fontSize: 11)),
        ],
      ),
    );
  }

  // ===== Time formatting helper (e.g. "2 min ago", "Yesterday") =====
  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final now = DateTime.now();
    final date = timestamp.toDate();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return DateFormat('h:mm a').format(date);
    if (diff.inDays == 1) return 'Yesterday';
    return DateFormat('dd MMM').format(date);
  }
}
