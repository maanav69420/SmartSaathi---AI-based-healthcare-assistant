import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../main.dart';
import '../services/notification_service.dart'; // ✅ ADDED

// ================= THEME =================
const Color elderlyPrimary = Color(0xFF2E5B85);
const Color elderlySecondary = Color(0xFF4A90A7);
const Color elderlyAccent = Color(0xFF7AB8C9);
const Color elderlyBackground = Color(0xFFF8FBFD);
const Color elderlyCard = Color(0xFFFFFFFF);
const Color elderlyTextPrimary = Color(0xFF1A1A1A);
const Color elderlyTextSecondary = Color(0xFF4A4A4A);

// ================= SCREEN =================
class HydrationAlertScreen extends StatefulWidget {
  const HydrationAlertScreen({super.key});

  @override
  State<HydrationAlertScreen> createState() => _HydrationAlertScreenState();
}

class _HydrationAlertScreenState extends State<HydrationAlertScreen> {
  final String baseUrl = "http://10.0.2.2:5000/api/hydration";

  late String email;
  List<String> alerts = [];

  @override
  void initState() {
    super.initState();
    email = loggedInUser;
    fetchAlerts();
  }

  // ================= API =================
  Future<void> fetchAlerts() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/alerts?email=$email"),
      );

      final data = jsonDecode(res.body);

      setState(() {
        alerts = List<String>.from(data["alerts"] ?? []);
      });

      // ✅ Schedule all alerts after fetching
      await _scheduleAllAlerts();

    } catch (e) {
      debugPrint("Error fetching alerts: $e");
    }
  }

  Future<void> autoSetup() async {
    await http.post(
      Uri.parse("$baseUrl/alerts/auto"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "wakeTime": "07:00",
        "sleepTime": "23:00",
      }),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Reminders set successfully"),
          backgroundColor: elderlyAccent,
        ),
      );
    }

    fetchAlerts();
  }

  void addAlertDialog() async {
  TimeOfDay? picked = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
  );

  if (picked != null) {
    final formatted =
        "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";

    addAlert(formatted); // ✅ ALWAYS 24-hour
  }
}

// ONLY showing updated parts (rest remains SAME)

Future<void> addAlert(String time) async {
  await http.post(
    Uri.parse("$baseUrl/alerts/add"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"email": email, "time": time}),
  );

  // ✅ SHOW NOTIFICATION
  await NotificationService.showInstantNotification(
    title: "⏰ Reminder Added",
    body: "Water reminder set for $time",
  );

  // ✅ SCHEDULE NOTIFICATION WITH BUTTON
  await NotificationService.scheduleHydrationNotificationWithAction(
    id: time.hashCode,
    scheduledTime: _nextInstanceOfTime(time),
    email: email,
  );

  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Reminder added for $time"),
        backgroundColor: elderlySecondary,
      ),
    );
  }

  fetchAlerts();
}

  Future<void> deleteAlert(int index) async {
    String time = alerts[index];

    await http.post(
      Uri.parse("$baseUrl/alerts/delete"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "index": index}),
    );

    // ✅ CANCEL NOTIFICATION
    await NotificationService.cancelNotification(time.hashCode);

    // ✅ SHOW NOTIFICATION
    await NotificationService.showInstantNotification(
      title: "🗑️ Reminder Removed",
      body: "Removed reminder at $time",
    );

    fetchAlerts();
  }

  // ================= HELPER =================
Future<void> _scheduleAllAlerts() async {
  for (String time in alerts) {
    await NotificationService.scheduleHydrationNotificationWithAction(
      id: time.hashCode,
      scheduledTime: _nextInstanceOfTime(time),
      email: email,
    );
  }
}

  DateTime _nextInstanceOfTime(String time) {
    final parts = time.split(" ");
    final timeParts = parts[0].split(":");

    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);

    if (parts.length > 1) {
      if (parts[1] == "PM" && hour != 12) {
        hour += 12;
      } else if (parts[1] == "AM" && hour == 12) {
        hour = 0;
      }
    }

    final now = DateTime.now();
    DateTime scheduled = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  // ================= STYLES =================
  TextStyle get _titleStyle => const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: elderlyTextPrimary,
      );

  TextStyle get _body => const TextStyle(
        fontSize: 20,
        color: elderlyTextSecondary,
      );

  TextStyle get _timeStyle => const TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        color: elderlyPrimary,
      );

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: elderlyBackground,
      appBar: AppBar(
        title: const Text(
          "Water Reminders",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: elderlyPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 28),
            onPressed: fetchAlerts,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerCard(),
            const SizedBox(height: 30),
            _actionButtons(),
            const SizedBox(height: 30),
            Text("Your Reminders", style: _titleStyle),
            const SizedBox(height: 16),
            Expanded(
              child: alerts.isEmpty
                  ? _emptyState()
                  : ListView.separated(
                      itemCount: alerts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (_, i) => _alertCard(i),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _headerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: elderlySecondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.notifications_active, size: 42, color: Colors.white),
          const SizedBox(height: 10),
          const Text(
            "Set reminders to drink water",
            style: TextStyle(fontSize: 22, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          const Text(
            "We'll remind you throughout the day",
            style: TextStyle(fontSize: 18, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ================= ACTION BUTTONS =================
  Widget _actionButtons() {
    return Row(
      children: [
        Expanded(child: _actionBtn(Icons.add, "Add Time", addAlertDialog)),
        const SizedBox(width: 14),
        Expanded(child: _actionBtn(Icons.auto_awesome, "Auto Setup", autoSetup)),
      ],
    );
  }

  Widget _actionBtn(IconData icon, String label, VoidCallback onTap) {
    return SizedBox(
      height: 75,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: elderlyCard,
          foregroundColor: elderlyPrimary,
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: onTap,
        icon: Icon(icon, size: 26),
        label: Text(label, style: const TextStyle(fontSize: 18)),
      ),
    );
  }

  // ================= EMPTY =================
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.water_drop_outlined,
              size: 60, color: elderlySecondary.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text("No reminders yet", style: _titleStyle),
          const SizedBox(height: 8),
          Text("Tap 'Add Time' to begin", style: _body),
        ],
      ),
    );
  }

  // ================= CARD =================
  Widget _alertCard(int index) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: elderlyCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: elderlyPrimary.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time, size: 30, color: elderlyPrimary),
          const SizedBox(width: 16),
          Expanded(
            child: Text(alerts[index], style: _timeStyle),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 28),
            onPressed: () => _confirmDelete(index),
          ),
        ],
      ),
    );
  }

  // ================= DELETE =================
  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Remove reminder?"),
        content: Text("Delete reminder at ${alerts[index]}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              deleteAlert(index);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}