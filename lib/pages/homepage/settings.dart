import 'package:chat_app/pages/onboardingpage.dart';
import 'package:chat_app/pages/profilepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../widgets/user_avatar.dart';

class Settingspage extends StatelessWidget {
  const Settingspage({super.key});

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Onboardingpage()),
      (route) => false,
    );
  }

  // ============================================================
  // SETTING ITEM
  // ============================================================

  Widget _settingItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 25, color: Colors.black87),

            const SizedBox(width: 18),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),

                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.black,

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,

        title: const Text(
          "Settings",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: Column(
        children: [
          const SizedBox(height: 25),

          Expanded(
            child: Container(
              width: double.infinity,

              decoration: const BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),

              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),

                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const SizedBox(height: 25),

                      // ==================================================
                      // PROFILE
                      // ==================================================
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProfilePage(),
                                ),
                              );
                            },
                            child: UserAvatar(
                              userId: FirebaseAuth.instance.currentUser!.uid,
                              fallbackName:
                                  FirebaseAuth
                                      .instance
                                      .currentUser
                                      ?.displayName ??
                                  "U",
                              radius: 30,
                            ),
                          ),

                          const SizedBox(width: 15),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.email ?? "No Email",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          IconButton(
                            onPressed: () {
                              print("Edit profile pressed");
                            },
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // ==================================================
                      // ACCOUNT
                      // ==================================================
                      _settingItem(
                        context: context,
                        icon: Icons.person_outline,
                        title: "Account",
                        subtitle: "Privacy, security, change number",
                        onTap: () {
                          print("Account pressed");
                        },
                      ),

                      // ==================================================
                      // CHAT
                      // ==================================================
                      _settingItem(
                        context: context,
                        icon: Icons.chat_bubble_outline,
                        title: "Chat",
                        subtitle: "Chat history, theme, wallpapers",
                        onTap: () {
                          print("Chat pressed");
                        },
                      ),

                      // ==================================================
                      // NOTIFICATIONS
                      // ==================================================
                      _settingItem(
                        context: context,
                        icon: Icons.notifications_none,
                        title: "Notifications",
                        subtitle: "Messages, group and others",
                        onTap: () {
                          print("Notifications pressed");
                        },
                      ),

                      // ==================================================
                      // HELP
                      // ==================================================
                      _settingItem(
                        context: context,
                        icon: Icons.help_outline,
                        title: "Help",
                        subtitle: "Help center, contact us, privacy policy",
                        onTap: () {
                          print("Help pressed");
                        },
                      ),

                      // ==================================================
                      // STORAGE AND DATA
                      // ==================================================
                      _settingItem(
                        context: context,
                        icon: Icons.data_usage,
                        title: "Storage and data",
                        subtitle: "Network usage, storage usage",
                        onTap: () {
                          print("Storage and data pressed");
                        },
                      ),

                      // ==================================================
                      // INVITE FRIEND
                      // ==================================================
                      _settingItem(
                        context: context,
                        icon: Icons.person_add_outlined,
                        title: "Invite a friend",
                        subtitle: "",
                        onTap: () {
                          print("Invite a friend pressed");
                        },
                      ),

                      const SizedBox(height: 25),

                      // ==================================================
                      // LOGOUT
                      // ==================================================
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _showLogoutDialog(context);
                          },

                          icon: const Icon(Icons.logout, color: Colors.red),

                          label: const Text(
                            "Logout",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOGOUT CONFIRMATION
  // ============================================================

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Logout"),

          content: const Text("Are you sure you want to logout?"),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(context);
                logout(context);
              },
              child: const Text("Logout", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
