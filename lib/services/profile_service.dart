import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ProfileService {
  static final _db = FirebaseFirestore.instance;

  // Image ko compress + resize karke Base64 string bana kar Firestore mein save karo
  static Future<void> uploadProfilePicture(File imageFile) async {
    final String uid = FirebaseAuth.instance.currentUser!.uid;

    // Compress: quality kam, size chhota (Firestore document 1MB se zyada nahi ho sakta)
    final Uint8List? compressedBytes =
        await FlutterImageCompress.compressWithFile(
          imageFile.absolute.path,
          minWidth: 300,
          minHeight: 300,
          quality: 60,
          format: CompressFormat.jpeg,
        );

    if (compressedBytes == null) {
      throw Exception("Image compress nahi ho saki");
    }

    // Safety check: agar phir bhi bara ho (>700KB) to error do
    if (compressedBytes.lengthInBytes > 700 * 1024) {
      throw Exception("Image bohat bari hai, chhoti image try karein");
    }

    final String base64Image = base64Encode(compressedBytes);

    await _db.collection('users').doc(uid).update({'photoBase64': base64Image});
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>> getUserStream() {
    final String uid = FirebaseAuth.instance.currentUser!.uid;
    return _db.collection('users').doc(uid).snapshots();
  }
}
