import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'screens/login.dart';
import 'screens/register.dart';
import 'screens/home.dart';
import 'screens/add_medication.dart';
import 'screens/view_medication.dart';
import 'screens/chatbot.dart';
import 'screens/settings.dart';
import 'screens/hydration.dart';

import 'services/notification_service.dart';

String loggedInUser = "";
String loggedInName = "";

/// ✅ LOCAL NOTIFICATION INSTANCE
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// ✅ Initialize Notification Service (IMPORTANT)
  await NotificationService.init();

  /// ✅ Initialize Local Notifications (for instant display if needed)
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/addMed': (context) => const AddMedicationScreen(),
        '/viewMed': (context) => const ViewMedicationScreen(),
        '/chatbot': (context) => const ChatbotScreen(),
        '/hydration': (context) => const HydrationScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}