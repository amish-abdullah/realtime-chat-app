import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // pubspec.yaml mein intl package add karo agar nahi hai

import '../../models/call_log_model.dart';
import '../../services/call_log_service.dart';

class Callspage extends StatelessWidget {
  const Callspage({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.black,
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
          "Calls",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey.shade500,
              child: const Icon(Icons.add_ic_call_sharp, color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 45),
          Expanded(
            child: Container(
              height: double.infinity,
              width: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 20, top: 20, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Recent Calls",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: StreamBuilder<List<CallLogModel>>(
                        stream: CallLogService.getCallLogs(currentUserId),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Text("Error: ${snapshot.error}"),
                            );
                          }
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final logs = snapshot.data!;

                          if (logs.isEmpty) {
                            return const Center(
                              child: Text(
                                "No calls yet",
                                style: TextStyle(color: Colors.grey),
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: logs.length,
                            itemBuilder: (context, index) {
                              final log = logs[index];
                              return _buildCallTile(log, currentUserId);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallTile(CallLogModel log, String currentUserId) {
    final bool isCaller = log.callerId == currentUserId;
    final String otherName = isCaller ? log.receiverName : log.callerName;
    final bool isMissed = log.status == 'missed';
    final bool isVideo = log.type == 'video';

    // dialed = maine call ki (outgoing arrow), received = mujhe call aayi (incoming arrow)
    final IconData directionIcon = isCaller
        ? Icons.call_made
        : Icons.call_received;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: Colors.grey.shade200,
        child: Text(
          otherName.isNotEmpty ? otherName[0].toUpperCase() : "?",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      title: Text(
        otherName.isEmpty ? "Unknown" : otherName,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isMissed ? Colors.red : Colors.black,
        ),
      ),
      subtitle: Row(
        children: [
          Icon(
            directionIcon,
            size: 15,
            color: isMissed ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 4),
          Text(
            _formatTimestamp(log.timestamp),
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
      trailing: Icon(
        isVideo ? Icons.videocam_outlined : Icons.call_outlined,
        color: Colors.black54,
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final isToday =
        dt.year == now.year && dt.month == now.month && dt.day == now.day;
    if (isToday) {
      return DateFormat('hh:mm a').format(dt);
    }
    return DateFormat('dd MMM, hh:mm a').format(dt);
  }
}
