import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/call_service.dart';
import 'call_screen.dart';

class IncomingCallScreen extends StatelessWidget {
  final String callId;
  final String callerName;
  final bool isVideoCall;

  const IncomingCallScreen({
    super.key,
    required this.callId,
    required this.callerName,
    required this.isVideoCall,
  });

  @override
  Widget build(BuildContext context) {
    final CallService callService = CallService();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            const CircleAvatar(
              radius: 70,
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, size: 75, color: Colors.white),
            ),

            const SizedBox(height: 25),

            Text(
              callerName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              isVideoCall ? "Incoming video call..." : "Incoming voice call...",
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),

            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ==============================
                // REJECT
                // ==============================
                Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await callService.rejectCall(callId);

                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      child: const CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.red,
                        child: Icon(
                          Icons.call_end,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Reject",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),

                const SizedBox(width: 80),

                // ==============================
                // ACCEPT
                // ==============================
                Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await callService.acceptCall(callId);

                        if (!context.mounted) return;

                        final currentUser = FirebaseAuth.instance.currentUser;

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CallScreen(
                              callId: callId,
                              userId: currentUser?.uid ?? '',
                              userName:
                                  currentUser?.displayName ??
                                  currentUser?.uid ??
                                  '',
                              isVideoCall: isVideoCall,
                            ),
                          ),
                        );
                      },
                      child: const CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.green,
                        child: Icon(Icons.call, color: Colors.white, size: 28),
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Accept",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
