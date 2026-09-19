import 'package:flutter/material.dart';

import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import 'package:chat_app/constants/zego_constants.dart' as zego;

class CallScreen extends StatelessWidget {
  final String callId;
  final String userId;
  final String userName;
  final bool isVideoCall;

  const CallScreen({
    super.key,
    required this.callId,
    required this.userId,
    required this.userName,
    required this.isVideoCall,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: ZegoUIKitPrebuiltCall(
          appID: zego.ZegoConstants.appID,
          appSign: zego.ZegoConstants.appSign,
          userID: userId,

          // FIX: username empty nahi hoga
          userName: userName.trim().isEmpty ? 'User' : userName.trim(),

          callID: callId,
          config: isVideoCall
              ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
              : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall(),
        ),
      ),
    );
  }
}
