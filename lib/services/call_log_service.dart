// lib/services/call_log_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/call_log_model.dart';

class CallLogService {
  static final _db = FirebaseFirestore.instance;

  static Future<void> saveCallLog({
    required String callerId,
    required String callerName,
    required String receiverId,
    required String receiverName,
    required String type,
    required String status,
    int duration = 0,
  }) async {
    await _db.collection('call_logs').add({
      'callerId': callerId,
      'callerName': callerName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'participants': [callerId, receiverId],
      'type': type,
      'status': status,
      'timestamp': FieldValue.serverTimestamp(),
      'duration': duration,
    });
  }

  // NAYA: current user ke saare call logs stream karo (latest sab se upar)
  static Stream<List<CallLogModel>> getCallLogs(String currentUserId) {
    return _db
        .collection('call_logs')
        .where('participants', arrayContains: currentUserId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CallLogModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }
}
