import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:gis_mobile/api/services/notification_service.dart';
import 'firebase_options.dart';
import 'package:gis_mobile/splash_screen.dart';
import 'package:http/http.dart' as http;



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

  // Request izin notifikasi
  await FirebaseMessaging.instance.requestPermission();

  // Ambil FCM Token
  String? token = await FirebaseMessaging.instance.getToken();

  print("FCM TOKEN DEVICE : $token");

  // Kirim token ke backend Laravel
  await sendTokenToBackend(token);

  // Token berubah? kirim ulang ke backend.
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    print("🔄 Token diperbarui: $newToken");
    sendTokenToBackend(newToken);
  });

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

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print("📩 Notifikasi diterima di background: ${message.notification?.title}");

  if (message.notification != null) {
    await NotificationService.showNotification(
      title: message.notification!.title ?? 'Notifikasi',
      body: message.notification!.body ?? '',
    );
  }
}

Future<void> sendTokenToBackend(String? token) async {
  if (token == null) return;

  const url = "https://nunggu dikirim xixixixi";

  await http.post(
    Uri.parse(url),
    body: {
      "token": token,
    },
  );
}
