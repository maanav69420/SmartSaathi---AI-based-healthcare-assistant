import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/notification_service.dart';
import '../main.dart';

class ViewMedicationScreen extends StatefulWidget {
  const ViewMedicationScreen({super.key});

  @override
  State<ViewMedicationScreen> createState() => _ViewMedicationScreenState();
}

class _ViewMedicationScreenState extends State<ViewMedicationScreen> {
  List data = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final res = await http.get(
        Uri.parse(
          "http://10.0.2.2:5000/medication/${Uri.encodeComponent(loggedInUser)}",
        ),
      );

      if (res.statusCode == 200) {
        setState(() {
          data = jsonDecode(res.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        _showErrorSnackBar("Failed to load medications");
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showErrorSnackBar("No internet connection");
    }
  }

  // ✅ DELETE FUNCTION
  Future<void> deleteMedication(String alarmName) async {
  try {
    final res = await http.delete(
      Uri.parse("http://10.0.2.2:5000/medication/delete"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": loggedInUser,
        "alarm_name": alarmName,
      }),
    );

    if (res.statusCode == 200) {

      // ✅ SHOW DELETE NOTIFICATION
      await NotificationService.showInstantNotification(
        title: "🗑️ Alarm Deleted",
        body: "$alarmName reminder removed",
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Medication deleted successfully"),
          backgroundColor: Colors.green,
        ),
      );

      fetchData();
    } else {
      _showErrorSnackBar("Failed to delete medication");
    }
  } catch (e) {
    _showErrorSnackBar("Error deleting medication");
  }
}

  // ✅ CONFIRM DIALOG
  void _confirmDelete(String alarmName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text("Delete Reminder"),
        content: const Text(
          "Are you sure you want to delete this medication reminder?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteMedication(alarmName);
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 18)),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: fetchData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "My Medications",
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
            onPressed: fetchData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Color(0xFF2E7D32),
                    strokeWidth: 4,
                  ),
                  SizedBox(height: 24),
                  Text(
                    "Loading your medications...",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          : data.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_pharmacy_outlined,
                          size: 80,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        "No Medications Added",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48),
                        child: Text(
                          "Add your medications to keep track of your daily routine",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 48),
                      SizedBox(
                        width: 240,
                        height: 72,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/addMed'),
                          icon: const Icon(Icons.add_circle_outline,
                              size: 32, color: Colors.white),
                          label: const Text(
                            "ADD MEDICATION",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchData,
                  color: const Color(0xFF2E7D32),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(24),
                    itemCount: data.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 20),
                    itemBuilder: (context, index) {
                      final med = data[index] as Map;

                      final name =
                          med['alarm_name']?.toString() ?? 'Unnamed';
                      final desc =
                          med['alarm_description']?.toString() ??
                              'No description';

                      final medsList =
                          (med['medication'] ?? []) as List;
                      final timersList =
                          (med['timers'] ?? []) as List;

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () {
                              _showMedicationDetails(context, med);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding:
                                            const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          gradient:
                                              const LinearGradient(
                                            colors: [
                                              Color(0xFF4CAF50),
                                              Color(0xFF2E7D32)
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(
                                                  20),
                                        ),
                                        child: const Icon(
                                          Icons.medication_liquid,
                                          size: 32,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                          children: [
                                            Text(
                                              name,
                                              style:
                                                  const TextStyle(
                                                fontSize: 28,
                                                fontWeight:
                                                    FontWeight.bold,
                                                color: Color(
                                                    0xFF1B5E20),
                                              ),
                                            ),
                                            Text(
                                              "${medsList.length} medicine${medsList.length != 1 ? 's' : ''} • ${timersList.length} time${timersList.length != 1 ? 's' : ''}",
                                              style: TextStyle(
                                                fontSize: 18,
                                                color:
                                                    Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // ✅ DELETE BUTTON
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red,
                                            size: 28),
                                        onPressed: () =>
                                            _confirmDelete(name),
                                      ),

                                      Icon(
                                        Icons.arrow_forward_ios,
                                        color:
                                            Colors.grey.shade400,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),

                                  Container(
                                    width: double.infinity,
                                    padding:
                                        const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius:
                                          BorderRadius.circular(16),
                                      border: const Border(
                                        left: BorderSide(
                                          color:
                                              Color(0xFF2E7D32),
                                          width: 4,
                                        ),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Instructions:",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight:
                                                FontWeight.w600,
                                            color:
                                                Color(0xFF1B5E20),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          desc.length > 100
                                              ? "${desc.substring(0, 100)}..."
                                              : desc,
                                          style:
                                              const TextStyle(
                                            fontSize: 20,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  void _showMedicationDetails(BuildContext context, Map med) {
    final medsList = (med['medication'] ?? []) as List;
    final timersList = (med['timers'] ?? []) as List;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Text(med['alarm_name'] ?? 'Medication'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(med['alarm_description'] ?? 'No description'),
            const SizedBox(height: 10),
            if (medsList.isNotEmpty)
              Text("Medicines: ${medsList.join(', ')}"),
            if (timersList.isNotEmpty)
              Text("Timers: ${timersList.join(', ')}"),
          ],
        ),
      ),
    );
  }
}