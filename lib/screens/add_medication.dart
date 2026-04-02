import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/notification_service.dart';
import '../main.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final name = TextEditingController();
  final desc = TextEditingController();

  List<String> meds = [];
  List<String> timers = [];

  @override
  void initState() {
    super.initState();

    name.addListener(() {
      setState(() {});
    });
  }

  void addMedication() async {await http.post(
    Uri.parse("http://10.0.2.2:5000/medication/add"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "email": loggedInUser,
      "alarm_name": name.text,
      "alarm_description": desc.text,
      "medication": meds,
      "timers": timers
    }),
  );

  // ✅ 1. SHOW "ALARM CREATED" NOTIFICATION
  await NotificationService.showInstantNotification(
    title: "✅ Alarm Created",
    body: "${name.text} reminder added successfully",
  );

  // ✅ 2. SCHEDULE MEDICATION REMINDERS
  int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

  for (String time in timers) {
    try {
      final now = DateTime.now();

      final parsedTime = TimeOfDay.fromDateTime(
        DateTime.parse("2020-01-01 ${_convertTo24Hour(time)}"),
      );

      DateTime scheduledDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        parsedTime.hour,
        parsedTime.minute,
      );

      if (scheduledDateTime.isBefore(now)) {
        scheduledDateTime = scheduledDateTime.add(const Duration(days: 1));
      }

      await NotificationService.scheduleNotification(
        id: notificationId++,
        title: "💊 Time to take ${name.text}",
        body: "${desc.text}\nMedicines: ${meds.join(', ')}",
        scheduledTime: scheduledDateTime,
      );
    } catch (e) {
      print("Error scheduling notification: $e");
    }
  }

  Navigator.pop(context);
}

// ✅ helper function (ADD BELOW addMedication)
String _convertTo24Hour(String time) {
  final parts = time.split(" ");
  final timeParts = parts[0].split(":");

  int hour = int.parse(timeParts[0]);
  int minute = int.parse(timeParts[1]);

  if (parts[1] == "PM" && hour != 12) {
    hour += 12;
  } else if (parts[1] == "AM" && hour == 12) {
    hour = 0;
  }

  return "$hour:$minute:00";}

  void addMedDialog() {
    TextEditingController temp = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.medication_liquid, size: 32, color: Color(0xFF2E7D32)),
            SizedBox(width: 12),
            Text(
              "Add Medicine",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: TextField(
          controller: temp,
          style: const TextStyle(fontSize: 20),
          decoration: InputDecoration(
            hintText: "e.g., Paracetamol 500mg",
            hintStyle: TextStyle(fontSize: 18, color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
  if (temp.text.trim().isNotEmpty) {
    meds.add(temp.text.trim());
    Navigator.pop(context);
    setState(() {});
  }
},
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade600,
            ),
            child: const Text("Cancel", style: TextStyle(fontSize: 18)),
          ),
          ElevatedButton(
            onPressed: () {
              if (temp.text.isNotEmpty) {
                meds.add(temp.text);
                Navigator.pop(context);
                setState(() {}); // Refresh UI
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text("Add", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> addTimerDialog() async {
  TimeOfDay? picked = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
  );

  if (picked != null) {
    final now = DateTime.now();
    final dt = DateTime(
      now.year,
      now.month,
      now.day,
      picked.hour,
      picked.minute,
    );

    final formattedTime = TimeOfDay.fromDateTime(dt).format(context);

    if (!timers.contains(formattedTime)) {
      timers.add(formattedTime);
      setState(() {});
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Add New Medication",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Main form card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.medication, size: 40, color: Color(0xFF2E7D32)),
                      SizedBox(width: 16),
                      Text(
                        "Medication Details",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  TextField(
                    controller: name,
                    style: const TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      labelText: "Medicine Name",
                      labelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      hintText: "e.g., Blood Pressure Tablet",
                      prefixIcon: const Icon(Icons.local_pharmacy, size: 28),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  TextField(
                    controller: desc,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      labelText: "Instructions",
                      labelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      hintText: "How to take, dosage, etc.",
                      prefixIcon: const Icon(Icons.description, size: 28),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Added medicines list
            if (meds.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.medication_liquid, size: 28, color: Color(0xFF2E7D32)),
                        const SizedBox(width: 12),
                        const Text(
                          "Medicines Added",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...meds.asMap().entries.map((entry) {
  int index = entry.key;
  String med = entry.value;

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        const Icon(Icons.circle, size: 12, color: Color(0xFF4CAF50)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(med, style: const TextStyle(fontSize: 18)),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: () {
            meds.removeAt(index);
            setState(() {});
          },
        ),
      ],
    ),
  );
}),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Add medicine button
            SizedBox(
              height: 72,
              child: ElevatedButton.icon(
                onPressed: addMedDialog,
                icon: const Icon(Icons.add_circle_outline, size: 32, color: Colors.white),
                label: const Text(
                  "ADD MEDICINE",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Added timers list
            if (timers.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 28, color: Color(0xFF2E7D32)),
                        const SizedBox(width: 12),
                        const Text(
                          "Timers Added",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...timers.asMap().entries.map((entry) {
  int index = entry.key;
  String timer = entry.value;

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        const Icon(Icons.circle, size: 12, color: Color(0xFF4CAF50)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(timer, style: const TextStyle(fontSize: 18)),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: () {
            timers.removeAt(index);
            setState(() {});
          },
        ),
      ],
    ),
  );
}),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Add timer button
            SizedBox(
              height: 72,
              child: ElevatedButton.icon(
                onPressed: addTimerDialog,
                icon: const Icon(Icons.schedule, size: 32, color: const Color(0xFF2E7D32)),
                label: const Text(
                  "ADD TIMER",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF2E7D32),
                  elevation: 8,
                  side: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Save button - prominent at bottom
            SizedBox(
              height: 80,
              child: ElevatedButton(
                onPressed: name.text.isNotEmpty && meds.isNotEmpty ? addMedication : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: name.text.isNotEmpty && meds.isNotEmpty 
                      ? const Color(0xFF2E7D32) 
                      : Colors.grey.shade400,
                  foregroundColor: Colors.white,
                  elevation: 12,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  textStyle: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text("SAVE MEDICATION"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}