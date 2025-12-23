import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gis_mobile/api/services/notification_service.dart';
import 'package:gis_mobile/pages/main_page.dart';
import 'package:gis_mobile/splash_screen.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Init NotificationService
  await NotificationService.init();

  // Background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Request izin notifikasi
  await FirebaseMessaging.instance.requestPermission();

  // Ambil FCM Token
  String? token = await FirebaseMessaging.instance.getToken();
  print("FCM TOKEN DEVICE : $token");

  // 🔑 Cek pertama kali buka aplikasi
  final prefs = await SharedPreferences.getInstance();
  final isFirstOpen = prefs.getBool('isFirstOpen') ?? true;

  if (isFirstOpen) {
    await prefs.setBool('isFirstOpen', false);
  }

  runApp(MyApp(isFirstOpen: isFirstOpen));
}

class MyApp extends StatelessWidget {
  final bool isFirstOpen;

  const MyApp({super.key, required this.isFirstOpen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mobile GIS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: false,
      ),
      home: isFirstOpen
          ? const SplashScreen()
          : const MainPage(),
    );
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print("📩 Notifikasi background: ${message.notification?.title}");

  if (message.notification != null) {
    await NotificationService.showNotification(
      title: message.notification!.title ?? 'Notifikasi',
      body: message.notification!.body ?? '',
    );
  }
}
