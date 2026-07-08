import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'di/injection_container.dart' as di;
import 'features/notifications/data/firebase_messaging_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (Assuming you will run flutterfire configure)
  // For now, we mock the initialization to allow the app to compile if Firebase Options are missing.
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase not initialized: $e");
  }

  // Initialize Dependency Injection
  await di.init();

  // Initialize Notifications
  final messagingService = FirebaseMessagingService();
  try {
    await messagingService.init();
  } catch (e) {
    debugPrint("Messaging service init error: $e");
  }

  runApp(const MyApp());
}

