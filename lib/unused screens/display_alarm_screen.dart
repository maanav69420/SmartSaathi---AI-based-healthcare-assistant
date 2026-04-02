import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../main.dart';

class DisplayAlarmScreen extends StatefulWidget {
  const DisplayAlarmScreen({super.key});

  @override
  State<DisplayAlarmScreen> createState() => _DisplayAlarmScreenState();
}

class _DisplayAlarmScreenState extends State<DisplayAlarmScreen> {
  List alarms = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAlarms();
  }

  Future<void> fetchAlarms() async {
    try {
      final res = await http.get(
        Uri.parse(
          "http://10.0.2.2:5000/get-alarms/${Uri.encodeComponent(loggedInUser)}",
        ),
      );

      if (res.statusCode == 200) {
        setState(() {
          alarms = jsonDecode(res.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Failed to load alarms. Please try again.",
              style: TextStyle(fontSize: 18),
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "No internet connection. Please check your connection.",
            style: TextStyle(fontSize: 18),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "My Medication Alarms",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white, size: 28),
            onPressed: fetchAlarms,
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                      color: Color(0xFF2E7D32), strokeWidth: 4),
                  SizedBox(height: 24),
                  Text(
                    "Loading your alarms...",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            )
          : alarms.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.access_time,
                          size: 64,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "No Alarms Yet",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Add your first medication alarm to get started",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton.icon(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/addMed'),
                        icon: const Icon(Icons.add, size: 28),
                        label: const Text(
                          "Add Alarm",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 20),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchAlarms,
                  color: const Color(0xFF2E7D32),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: alarms.length,
                    itemBuilder: (context, index) {
                      final alarmData = alarms[index];

                      // ✅ Safe extraction
                      final a = alarmData["alarm_info"] ?? alarmData;

                      final alarmName =
                          a["alarm_name"] ?? "Unnamed Alarm";
                      final timers = a["timers"] ?? [];
                      final meds = a["medication"] ?? [];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        child: Card(
                          elevation: 8,
                          shadowColor:
                              Colors.green.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding:
                                          const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF4CAF50)
                                            .withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(16),
                                      ),
                                      child: const Icon(
                                        Icons.alarm_on,
                                        size: 32,
                                        color:
                                            Color(0xFF2E7D32),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                        children: [
                                          Text(
                                            alarmName,
                                            style:
                                                const TextStyle(
                                              fontSize: 26,
                                              fontWeight:
                                                  FontWeight.bold,
                                              color: Color(
                                                  0xFF1B5E20),
                                            ),
                                          ),
                                          Text(
                                            "${meds.length} medicine${meds.length != 1 ? 's' : ''}",
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors
                                                  .grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                if (timers.isNotEmpty) ...[
                                  const Text(
                                    "Reminders:",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight:
                                          FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ...timers.map<Widget>((timer) =>
                                      Text(
                                        timer.toString(),
                                        style:
                                            const TextStyle(
                                                fontSize: 20),
                                      )),
                                ],

                                if (meds.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  const Text(
                                    "Medicines:",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight:
                                          FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ...meds.map<Widget>((med) =>
                                      Text(
                                        med.toString(),
                                        style:
                                            const TextStyle(
                                                fontSize: 20),
                                      )),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}