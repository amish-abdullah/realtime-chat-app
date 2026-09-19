import 'package:cloud_firestore/cloud_firestore.dart';

class CallLogModel {
  final String id;
  final String callerId;
  final String callerName;
  final String receiverId;
  final String receiverName;
  final String type; // "audio" ya "video"
  final String status; // "dialed", "received", "missed", "declined"
  final DateTime timestamp;
  final int duration; // seconds

  CallLogModel({
    required this.id,
    required this.callerId,
    required this.callerName,
    required this.receiverId,
    required this.receiverName,
    required this.type,
    required this.status,
    required this.timestamp,
    required this.duration,
  });

  factory CallLogModel.fromMap(String id, Map<String, dynamic> map) {
    return CallLogModel(
      id: id,
      callerId: map['callerId'] ?? '',
      callerName: map['callerName'] ?? '',
      receiverId: map['receiverId'] ?? '',
      receiverName: map['receiverName'] ?? '',
      type: map['type'] ?? 'audio',
      status: map['status'] ?? 'dialed',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      duration: map['duration'] ?? 0,
    );
  }
}
