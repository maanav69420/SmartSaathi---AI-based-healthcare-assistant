import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:http/http.dart' as http;
import '../main.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  NotificationService.handleAction(
    response.payload,
    actionId: response.actionId, // ✅ CRITICAL FIX
  );
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String baseUrl = "http://10.0.2.2:5000/api/hydration";

  // ✅ INIT FUNCTION
  static Future<void> init() async {
    // 🔹 Android initialization
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(android: androidInit);

    await notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) async {
  await NotificationService.handleAction(
    response.payload,
    actionId: response.actionId,
  );
},
onDidReceiveBackgroundNotificationResponse:
      notificationTapBackground,
    );


    // 🔹 Timezone setup
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    // 🔹 Request notification permission (Android 13+)
    final androidPlugin = notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();

    // 🔹 Create notification channels (VERY IMPORTANT)
    const AndroidNotificationChannel medChannel =
        AndroidNotificationChannel(
      'med_channel',
      'Medication Reminder',
      description: 'Reminds you to take medicines',
      importance: Importance.max,
    );

    const AndroidNotificationChannel instantChannel =
        AndroidNotificationChannel(
      'instant_channel',
      'Instant Notifications',
      description: 'Shows instant alerts',
      importance: Importance.max,
    );

    // ✅ NEW CHANNEL (Hydration)
    const AndroidNotificationChannel hydrationChannel =
        AndroidNotificationChannel(
      'hydration_channel',
      'Hydration Reminder',
      description: 'Reminds you to drink water',
      importance: Importance.max,
    );

    await androidPlugin?.createNotificationChannel(medChannel);
    await androidPlugin?.createNotificationChannel(instantChannel);
    await androidPlugin?.createNotificationChannel(hydrationChannel); // ✅ ADDED
  }

  // ✅ HANDLE NOTIFICATION ACTION CLICK
  static Future<void> onNotificationTap(
      NotificationResponse response) async {
    if (response.actionId == "drink_250") {
      try {
        await http.post(
          Uri.parse("$baseUrl/add"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "email": loggedInUser,
            "amount": 250,
          }),
        );

        // ✅ CONFIRMATION NOTIFICATION
        await showInstantNotification(
          title: "💧 Intake Updated",
          body: "Added 250 ml to your hydration",
        );
      } catch (e) {
        print("Error updating hydration: $e");
      }
    }
  }

  // ✅ INSTANT NOTIFICATION (Add/Delete)
  static Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    await notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'instant_channel',
          'Instant Notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  // ✅ SCHEDULED MEDICATION NOTIFICATION (UNCHANGED)
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

    print("Scheduling notification at: $tzTime");

    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'med_channel',
          'Medication Reminder',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ================= NEW FEATURES (HYDRATION) =================

  // ✅ SCHEDULE HYDRATION NOTIFICATION
  static Future<void> scheduleHydrationNotification({
    required int id,
    required DateTime scheduledTime,
  }) async {
    final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

    await notificationsPlugin.zonedSchedule(
      id,
      "💧 Drink Water Reminder",
      "Stay hydrated! Tap after drinking.",
      tzTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'hydration_channel',
          'Hydration Reminder',
          importance: Importance.max,
          priority: Priority.high,
          actions: [
            AndroidNotificationAction(
  'drink_250',
  'I drank 250 ml',
  showsUserInterface: true, // REQUIRED
),
          ],
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

static Future<void> handleAction(String? payload,
    {String? actionId}) async {
  try {
    // ✅ Handle button click
    if (actionId == "drink_250") {
      await http.post(
        Uri.parse("http://10.0.2.2:5000/api/hydration/add"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": loggedInUser,
          "amount": 250,
        }),
      );

      await showInstantNotification(
        title: "💧 Intake Updated",
        body: "Added 250 ml to your hydration",
      );
      return;
    }

    // ✅ Handle normal tap
    if (payload != null) {
      final data = jsonDecode(payload);

      if (data["type"] == "drink_water") {
        await http.post(
          Uri.parse("http://10.0.2.2:5000/api/hydration/add"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "email": data["email"],
            "amount": 250,
          }),
        );
      }
    }
  } catch (e) {
    print("Action error: $e");
  }
}

static Future<void> scheduleHydrationNotificationWithAction({
  required int id,
  required DateTime scheduledTime,
  required String email,
}) async {
  final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

  await notificationsPlugin.zonedSchedule(
    id,
    "💧 Time to Drink Water",
    "Stay hydrated! Tap below after drinking",
    tzTime,
    NotificationDetails(
      android: AndroidNotificationDetails(
        'hydration_channel',
'Hydration Reminder',
        importance: Importance.max,
        priority: Priority.high,
        actions: [
          AndroidNotificationAction(
  'drink_250',
  'I drank 250 ml',
  showsUserInterface: true, // REQUIRED
),
        ],
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    matchDateTimeComponents: DateTimeComponents.time,
    payload: jsonEncode({
      "type": "drink_water",
      "email": email,
    }),
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
  );
}

  // ✅ CANCEL NOTIFICATION (for delete)
  static Future<void> cancelNotification(int id) async {
    await notificationsPlugin.cancel(id);
  }
}