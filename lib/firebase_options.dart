import 'package:firebase_core/firebase_core.dart';
import 'dart:io';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (Platform.isAndroid) return android;
    return web;
  }

  // ✅ ANDROID (ambil dari google-services.json)
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyDvEResfn8a1WVvRF5Dbh0II-WeflVhJjQ",
    appId: "1:1020171634165:android:9e6a7dea460a1258740cbc",
    messagingSenderId: "1020171634165",
    projectId: "gis-mobile-b459c",
    storageBucket: "gis-mobile-b459c.firebasestorage.app",
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyC_qWe-7HMMs7oRm2YvmXJJKGYx391S0pw",
    authDomain: "gis-mobile-b459c.firebaseapp.com",
    projectId: "gis-mobile-b459c",
    storageBucket: "gis-mobile-b459c.firebasestorage.app",
    messagingSenderId: "1020171634165",
    appId: "1:1020171634165:web:1720274ce0d93ac4740cbc",
    measurementId: "G-SW64R2F30G",
  );
}
