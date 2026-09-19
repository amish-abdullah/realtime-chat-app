// lib/services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings: initSettings);
    _initialized = true;
  }

  Future<void> showMessageNotification({
    required String title,
    required String body,
    required String chatId,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'chat_messages_channel',
      'Chat Messages',
      channelDescription: 'Notifications for new chat messages',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    // chatId ke hash se ek stable notification id banate hain
    await _plugin.show(
      id: chatId.hashCode,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }
}

// ============================================================
// CURRENTLY OPEN CHAT TRACKER
// ============================================================
// Jab user kisi chat screen ke andar ho, uska chatId yahan set
// hota hai — taake us specific chat ka naya message aane par
// notification na dikhaye (jaisa WhatsApp karta hai).
class OpenChatTracker {
  static String? currentOpenChatId;
}
