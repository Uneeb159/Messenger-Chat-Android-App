import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  // 🔐 Your Firebase Project ID
  static const String _projectId = 'fuse-chat'; // Update if different

  // 📦 Instance of Flutter Local Notifications
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // ✅ Initializes local notification plugin (to display)
  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings iOSSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    final InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        // You can handle click behavior here
        print('🔔 Notification tapped');
      },
    );
  }

  // 🔔 Show push notification locally (foreground/background)
  static Future<void> showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'messenger_chat_channel', // Channel ID
          'Messenger Chat Notifications', // Channel name
          channelDescription: 'Channel for Messenger Chat push notifications',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.show(
      message.notification.hashCode,
      message.notification?.title ?? 'New Message',
      message.notification?.body ?? '',
      platformDetails,
    );
  }

  // 📤 Send notification via FCM HTTP v1
  static Future<void> sendPushNotification({
    required String token,
    required String title,
    required String body,
    required String accessToken,
  }) async {
    final url = Uri.parse(
      'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send',
    );

    final Map<String, dynamic> message = {
      "message": {
        "token": token,
        "notification": {"title": title, "body": body},
        "android": {"priority": "high"},
        "apns": {
          "headers": {"apns-priority": "10"},
        },
      },
    };

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print('✅ Notification sent successfully');
    } else {
      print(
        '❌ Failed to send notification: ${response.statusCode} ${response.body}',
      );
    }
  }
}
