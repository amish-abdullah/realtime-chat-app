import 'package:cloud_firestore/cloud_firestore.dart';

class CallService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================================
  // START CALL
  // ============================================================

  Future<String> startCall({
    required String callerId,
    required String callerName,
    required String receiverId,
    required String receiverName,
    required bool isVideoCall,
  }) async {
    final callDoc = _firestore.collection('calls').doc();

    await callDoc.set({
      'callId': callDoc.id,
      'callerId': callerId,
      'callerName': callerName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'isVideoCall': isVideoCall,

      // ringing -> accepted -> rejected -> ended
      'status': 'ringing',

      // Agora channel name
      'channelName': callDoc.id,

      'createdAt': FieldValue.serverTimestamp(),
    });

    return callDoc.id;
  }

  // ============================================================
  // LISTEN FOR INCOMING CALLS
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> listenForIncomingCalls(
    String userId,
  ) {
    return _firestore
        .collection('calls')
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: 'ringing')
        .snapshots();
  }

  // ============================================================
  // LISTEN TO ONE CALL
  // ============================================================

  Stream<DocumentSnapshot<Map<String, dynamic>>> listenToCallStatus(
    String callId,
  ) {
    return _firestore.collection('calls').doc(callId).snapshots();
  }

  // ============================================================
  // ACCEPT CALL
  // ============================================================

  Future<void> acceptCall(String callId) async {
    await _firestore.collection('calls').doc(callId).update({
      'status': 'accepted',
    });
  }

  // ============================================================
  // REJECT CALL
  // ============================================================

  Future<void> rejectCall(String callId) async {
    await _firestore.collection('calls').doc(callId).update({
      'status': 'rejected',
    });
  }

  // ============================================================
  // END CALL
  // ============================================================

  Future<void> endCall(String callId) async {
    await _firestore.collection('calls').doc(callId).update({
      'status': 'ended',
    });
  }
}
