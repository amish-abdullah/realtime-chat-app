import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserAvatar extends StatelessWidget {
  final String userId;
  final String fallbackName;
  final double radius;

  const UserAvatar({
    super.key,
    required this.userId,
    required this.fallbackName,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots(),
      builder: (context, snapshot) {
        final String? base64Str = snapshot.data?.data()?['photoBase64'];

        ImageProvider? image;
        if (base64Str != null && base64Str.isNotEmpty) {
          try {
            image = MemoryImage(base64Decode(base64Str));
          } catch (_) {
            image = null;
          }
        }

        return CircleAvatar(
          radius: radius,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: image,
          child: image == null
              ? Text(
                  fallbackName.isNotEmpty ? fallbackName[0].toUpperCase() : "?",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: radius * 0.7,
                  ),
                )
              : null,
        );
      },
    );
  }
}
