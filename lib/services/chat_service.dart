// services/chat_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================================
  // CONSISTENT CHAT ID
  // ============================================================

  // Dono users ke liye same chatId banega
  String getChatId(String uid1, String uid2) {
    List<String> ids = [uid1, uid2];
    ids.sort();
    return ids.join("_");
  }

  // ============================================================
  // TYPING STATUS
  // ============================================================

  // Current user ka typing status Firestore mein save karna
  Future<void> setTypingStatus(
    String currentUserId,
    String otherUserId,
    bool isTyping,
  ) async {
    final chatId = getChatId(currentUserId, otherUserId);

    try {
      await _firestore.collection('chats').doc(chatId).set({
        'typing': {currentUserId: isTyping},
      }, SetOptions(merge: true));

      print("Typing status saved: $currentUserId = $isTyping");
    } catch (e) {
      print("ERROR setting typing status: $e");
    }
  }

  // Doosre user ka typing status real-time sunna
  Stream<bool> getTypingStatus(String currentUserId, String otherUserId) {
    final chatId = getChatId(currentUserId, otherUserId);

    return _firestore.collection('chats').doc(chatId).snapshots().map((doc) {
      // Agar chat document exist nahi karta
      if (!doc.exists) {
        return false;
      }

      final data = doc.data();

      // Agar data null hai
      if (data == null) {
        return false;
      }

      // typing field get karo
      final typing = data['typing'];

      // Agar typing Map nahi hai
      if (typing is! Map) {
        return false;
      }

      // Sirf doosre user ka status return karna hai
      final isTyping = typing[otherUserId];

      return isTyping == true;
    });
  }

  // ============================================================
  // MARK MESSAGES AS READ
  // ============================================================

  // Jab receiver chat kholay,
  // doosre user ke unread messages ko read mark karna
  Future<void> markMessagesAsRead(
    String currentUserId,
    String otherUserId,
  ) async {
    final chatId = getChatId(currentUserId, otherUserId);

    final unreadMessages = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('senderId', isEqualTo: otherUserId)
        .where('status', isNotEqualTo: 'read')
        .get();

    final batch = _firestore.batch();

    for (var doc in unreadMessages.docs) {
      batch.update(doc.reference, {'status': 'read'});
    }

    await batch.commit();

    // Current user ka unread count 0
    await _firestore.collection('chats').doc(chatId).set({
      'unreadCount.$currentUserId': 0,
    }, SetOptions(merge: true));
  }

  // ============================================================
  // SEND MESSAGE
  // ============================================================

  // Message bhejna
  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String text,
  }) async {
    final chatId = getChatId(senderId, receiverId);

    final messageRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc();

    final message = MessageModel(
      id: messageRef.id,
      senderId: senderId,
      text: text,
      type: 'text',
      timestamp: null,
      status: 'sent',
    );

    // Message Firestore mein save
    await messageRef.set(message.toMap());

    // Chat document update/create
    await _firestore.collection('chats').doc(chatId).set({
      'participants': [senderId, receiverId],
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastSenderId': senderId,
    }, SetOptions(merge: true));
  }

  // ============================================================
  // GET MESSAGES
  // ============================================================

  // Messages ki real-time stream
  Stream<List<MessageModel>> getMessages(String uid1, String uid2) {
    final chatId = getChatId(uid1, uid2);

    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // ============================================================
  // GET USER CHATS
  // ============================================================

  // Current user ki saari chats
  // Homepage / Chat List ke liye
  Stream<QuerySnapshot> getUserChats(String currentUserId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }
}
