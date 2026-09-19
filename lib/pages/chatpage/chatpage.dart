import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import '../../services/chat_service.dart';
import '../../models/message_model.dart';
import '../../services/notification_service.dart';

class Chatpage extends StatefulWidget {
  final String receiverId;
  final String receiverName;

  const Chatpage({
    super.key,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<Chatpage> createState() => _ChatpageState();
}

class _ChatpageState extends State<Chatpage> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  Timer? _typingTimer;
  bool _isCurrentlyTyping = false;
  bool _isMarkingAsRead = false;

  @override
  void initState() {
    super.initState();
    _markMessagesAsRead();
    OpenChatTracker.currentOpenChatId = _chatService.getChatId(
      currentUserId,
      widget.receiverId,
    );
    _messageController.addListener(_onTypingChanged);
  }

  String get _safeReceiverName {
    if (widget.receiverName.trim().isEmpty) {
      return "User_${widget.receiverId.substring(0, 6)}";
    }
    return widget.receiverName.trim();
  }

  Future<void> _markMessagesAsRead() async {
    if (_isMarkingAsRead) return;
    _isMarkingAsRead = true;
    try {
      await _chatService.markMessagesAsRead(currentUserId, widget.receiverId);
    } catch (e) {
      print("ERROR marking messages as read: $e");
    } finally {
      _isMarkingAsRead = false;
    }
  }

  void _onTypingChanged() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      if (!_isCurrentlyTyping) {
        _isCurrentlyTyping = true;
        _chatService
            .setTypingStatus(currentUserId, widget.receiverId, true)
            .catchError((e) {});
      }
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 2), () {
        _stopTyping();
      });
    } else {
      _typingTimer?.cancel();
      if (_isCurrentlyTyping) {
        _stopTyping();
      }
    }
  }

  void _stopTyping() {
    _isCurrentlyTyping = false;
    _chatService
        .setTypingStatus(currentUserId, widget.receiverId, false)
        .catchError((e) {});
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _typingTimer?.cancel();
    if (_isCurrentlyTyping) _stopTyping();
    _messageController.clear();

    try {
      await _chatService.sendMessage(
        senderId: currentUserId,
        receiverId: widget.receiverId,
        text: text,
      );
    } catch (e) {
      print("ERROR sending message: $e");
    }
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTypingChanged);
    _typingTimer?.cancel();
    _chatService.setTypingStatus(currentUserId, widget.receiverId, false);
    OpenChatTracker.currentOpenChatId = null;
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 21,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: StreamBuilder<bool>(
          stream: _chatService.getTypingStatus(
            currentUserId,
            widget.receiverId,
          ),
          builder: (context, snapshot) {
            final bool isTyping = snapshot.data ?? false;
            return Row(
              children: [
                CircleAvatar(
                  radius: 21,
                  backgroundColor: Colors.grey.shade200,
                  child: Text(
                    widget.receiverName.isNotEmpty
                        ? widget.receiverName[0].toUpperCase()
                        : "?",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.receiverName,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isTyping ? "typing..." : "Active now",
                      style: TextStyle(
                        color: isTyping ? Colors.green : Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          // ====================================================
          // VOICE CALL INVITATION BUTTON (WhatsApp Style)
          // ====================================================
          ZegoSendCallInvitationButton(
            isVideoCall: false,
            // FIXED: console mein resourceID ka naam "zegouikit_call" hai
            resourceID: "zegouikit_call",
            invitees: [
              ZegoUIKitUser(id: widget.receiverId, name: _safeReceiverName),
            ],
            icon: ButtonIcon(
              icon: const Icon(Icons.call_outlined, color: Colors.black),
            ),
            iconSize: const Size(40, 40),
            buttonSize: const Size(40, 40),
          ),

          // ====================================================
          // VIDEO CALL INVITATION BUTTON (WhatsApp Style)
          // ====================================================
          ZegoSendCallInvitationButton(
            isVideoCall: true,
            // FIXED: console mein resourceID ka naam "zegouikit_call" hai
            resourceID: "zegouikit_call",
            invitees: [
              ZegoUIKitUser(id: widget.receiverId, name: _safeReceiverName),
            ],
            icon: ButtonIcon(
              icon: const Icon(Icons.videocam_outlined, color: Colors.black),
            ),
            iconSize: const Size(40, 40),
            buttonSize: const Size(40, 40),
          ),

          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () => _showMoreMenu(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: _chatService.getMessages(
                currentUserId,
                widget.receiverId,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!;

                if (messages.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) _markMessagesAsRead();
                  });
                }

                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      "Say hi! 👋",
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 15),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final bool isMe = msg.senderId == currentUserId;
                    return _buildMessageBubble(msg, isMe);
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(left: 5, bottom: 5),
                child: Text(
                  widget.receiverName,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFFE9E9E9) : const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
              ),
              child: Text(
                msg.text,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "09:25 AM",
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    msg.status == 'read' ? Icons.done_all : Icons.done,
                    size: 15,
                    color: msg.status == 'read'
                        ? Colors.blue
                        : Colors.grey.shade600,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.emoji_emotions_outlined,
                color: Colors.grey.shade700,
                size: 25,
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F4F4),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _messageController,
                  maxLines: 4,
                  minLines: 1,
                  decoration: const InputDecoration(
                    hintText: "Write your message",
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 17,
                      vertical: 11,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 5),
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.attach_file,
                color: Colors.grey.shade700,
                size: 24,
              ),
            ),
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _sendMessage,
                icon: const Icon(
                  Icons.arrow_upward,
                  color: Colors.white,
                  size: 21,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 15),
              ListTile(
                leading: const Icon(Icons.search),
                title: const Text("Search messages"),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.notifications_off_outlined),
                title: const Text("Mute notifications"),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text("Clear chat"),
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}
