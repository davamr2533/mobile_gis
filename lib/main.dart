import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:gis_mobile/api/services/notification_service.dart';
import 'firebase_options.dart';
import 'package:gis_mobile/splash_screen.dart';

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print("📩 Notifikasi diterima di background: ${message.notification?.title}");

  // Bisa juga panggil local notification kalau mau heads-up di background
  if (message.notification != null) {
    await NotificationService.showNotification(
      title: message.notification!.title ?? 'Notifikasi',
      body: message.notification!.body ?? '',
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Init NotificationService
  await NotificationService.init();

  // Background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Minta izin notifikasi
  await FirebaseMessaging.instance.requestPermission();

  // Ambil FCM Token
  String? token = await FirebaseMessaging.instance.getToken();

  print("🔥 FCM TOKEN DEVICE INI: $token");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mobile GIS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: false,
      ),
      home: const SplashScreen(),
    );
  }
}
