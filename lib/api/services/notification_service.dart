import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Android initialization
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
    InitializationSettings(android: androidSettings);

    await _notifications.initialize(settings);

    // FCM listener untuk foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (message.notification != null) {
        await showNotification(
          title: message.notification!.title ?? 'Notifikasi',
          body: message.notification!.body ?? '',
        );
      }
    });
  }

  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'default_channel', // id channel
      'Default', // nama channel
      channelDescription: 'Channel notifikasi default',
      importance: Importance.max,  // HEADS-UP
      priority: Priority.high,     // HEADS-UP
      playSound: true,
      ticker: 'ticker',
    );

    const NotificationDetails platformDetails =
    NotificationDetails(android: androidDetails);

    await _notifications.show(
      0, // id unik tiap notif
      title,
      body,
      platformDetails,
    );
  }
}
