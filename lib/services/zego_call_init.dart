import 'package:flutter/foundation.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'package:chat_app/constants/zego_constants.dart' as zego;
import 'package:chat_app/services/call_log_service.dart';

Future<void> initZegoCallInvitationService({
  required String userId,
  required String userName,
}) async {
  final String safeUserName = userName.trim().isEmpty
      ? 'User'
      : userName.trim();

  DateTime callStartedAt = DateTime.now();
  bool isVideoCall = false;
  ZegoUIKitUser? otherPartyUser;
  bool isCurrentUserCaller = false;

  await ZegoUIKitPrebuiltCallInvitationService().init(
    appID: zego.ZegoConstants.appID,
    appSign: zego.ZegoConstants.appSign,
    userID: userId,
    userName: safeUserName,
    plugins: [ZegoUIKitSignalingPlugin()],

    requireConfig: (ZegoCallInvitationData data) {
      isVideoCall = data.type == ZegoCallInvitationType.videoCall;
      isCurrentUserCaller = data.inviter?.id == userId;
      otherPartyUser = isCurrentUserCaller
          ? (data.invitees.isNotEmpty
                ? data.invitees.first
                : ZegoUIKitUser(id: '', name: ''))
          : (data.inviter ?? ZegoUIKitUser(id: '', name: ''));

      callStartedAt = DateTime.now();

      debugPrint(
        "📞 requireConfig fired | isVideoCall=$isVideoCall | isCaller=$isCurrentUserCaller | other=${otherPartyUser?.id}",
      );

      return isVideoCall
          ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
          : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();
    },

    // onCallEnd yahin, top-level events param mein hi sahi hai (Zego docs ke mutabiq)
    events: ZegoUIKitPrebuiltCallEvents(
      onCallEnd: (event, defaultAction) async {
        debugPrint("📞 onCallEnd fired! reason=${event.reason}");

        final int duration = DateTime.now().difference(callStartedAt).inSeconds;
        final ZegoUIKitUser other =
            otherPartyUser ?? ZegoUIKitUser(id: '', name: '');

        debugPrint(
          "📞 Saving log -> duration=${duration}s caller=$isCurrentUserCaller otherId=${other.id}",
        );

        try {
          await CallLogService.saveCallLog(
            callerId: isCurrentUserCaller ? userId : other.id,
            callerName: isCurrentUserCaller ? safeUserName : other.name,
            receiverId: isCurrentUserCaller ? other.id : userId,
            receiverName: isCurrentUserCaller ? other.name : safeUserName,
            type: isVideoCall ? 'video' : 'audio',
            status: duration > 3
                ? (isCurrentUserCaller ? 'dialed' : 'received')
                : 'missed',
            duration: duration,
          );
          debugPrint("✅ Call log saved to Firestore successfully");
        } catch (e) {
          debugPrint("❌ ERROR saving call log: $e");
        }

        defaultAction.call();
      },
    ),
  );
}
