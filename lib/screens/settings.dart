import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ageController = TextEditingController();
  final weightController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();

  String wakeTime = "";
  String sleepTime = "";

  bool isLoading = false;

  // ---------------- API CALLS w/ Error Handling ----------------
  Future<void> updateRoutine() async {
    if (wakeTime.isEmpty && sleepTime.isEmpty) {
      _showError("Please select both times");
      return;
    }

    setState(() => isLoading = true);
    try {
      await http.put(
        Uri.parse("http://10.0.2.2:5000/user/update-routine"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": loggedInUser,
          "wakeTime": wakeTime,
          "sleepTime": sleepTime
        }),
      );
      _showSuccess("✅ Routine updated successfully!");
    } catch (e) {
      _showError("Failed to update routine");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> updateWeight() async {
    final weight = int.tryParse(weightController.text.trim());
    if (weight == null || weight <= 0) {
      _showError("Please enter valid weight");
      return;
    }

    setState(() => isLoading = true);
    try {
      await http.put(
        Uri.parse("http://10.0.2.2:5000/user/update-weight"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": loggedInUser,
          "weight": weight
        }),
      );
      _showSuccess("✅ Weight updated: ${weight}kg");
      weightController.clear();
    } catch (e) {
      _showError("Failed to update weight");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> updateAge() async {
    final age = int.tryParse(ageController.text.trim());
    if (age == null || age <= 0 || age > 120) {
      _showError("Please enter valid age (1-120)");
      return;
    }

    setState(() => isLoading = true);
    try {
      await http.put(
        Uri.parse("http://10.0.2.2:5000/user/update-age"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": loggedInUser,
          "age": age
        }),
      );
      _showSuccess("✅ Age updated: ${age} years");
      ageController.clear();
    } catch (e) {
      _showError("Failed to update age");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> updateCredentials() async {
    if (nameController.text.trim().isNotEmpty) {
  loggedInName = nameController.text.trim(); // update UI instantly
}

    setState(() => isLoading = true);
    try {
      await http.put(
        Uri.parse("http://10.0.2.2:5000/user/update-credentials"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": loggedInUser,
          "name": nameController.text.trim().isEmpty ? null : nameController.text.trim(),
          "password": passwordController.text.trim().isEmpty ? null : passwordController.text.trim()
        }),
      );
      _showSuccess("✅ Profile updated successfully!");
      nameController.clear();
      passwordController.clear();
    } catch (e) {
      _showError("Failed to update profile");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 18)),
        backgroundColor: Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 18)),
        backgroundColor: Colors.orange.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ---------------- ELDER-FRIENDLY UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile header
            Container(
              margin: const EdgeInsets.only(bottom: 40),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 25,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: const Color(0xFF4CAF50),
                    child: Text(
                      loggedInUser.isNotEmpty ? loggedInUser[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    loggedInUser,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  Text(
                    "Tap sections below to update",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // ✅ ROUTINE SECTION
            _buildSection(
              title: "Daily Routine",
              icon: Icons.schedule,
              children: [
                _buildTimeTile("Wake Up Time", wakeTime, Icons.wb_sunny_outlined, () => _pickTime(true)),
                const SizedBox(height: 20),
                _buildTimeTile("Sleep Time", sleepTime, Icons.nights_stay_outlined, () => _pickTime(false)),
                const SizedBox(height: 28),
                _buildActionButton("Update Routine", updateRoutine, Icons.update),
              ],
            ),

            const SizedBox(height: 32),

            // ✅ WEIGHT SECTION
            _buildSection(
              title: "Weight",
              icon: Icons.fitness_center,
              children: [
                _buildInputField(weightController, "Weight (kg)", Icons.balance_outlined, TextInputType.number),
                const SizedBox(height: 28),
                _buildActionButton("Update Weight", updateWeight, Icons.fitness_center_outlined),
              ],
            ),

            const SizedBox(height: 32),

            // ✅ AGE SECTION
            _buildSection(
              title: "Age",
              icon: Icons.cake,
              children: [
                _buildInputField(ageController, "Age (years)", Icons.cake_outlined, TextInputType.number),
                const SizedBox(height: 28),
                _buildActionButton("Update Age", updateAge, Icons.cake),
              ],
            ),

            const SizedBox(height: 32),

            // ✅ CREDENTIALS SECTION
            _buildSection(
              title: "Profile",
              icon: Icons.person,
              children: [
                _buildInputField(nameController, "New Name", Icons.person_outline, TextInputType.name),
                const SizedBox(height: 20),
                _buildInputField(passwordController, "New Password", Icons.lock_outline, TextInputType.visiblePassword, obscureText: true),
                const SizedBox(height: 28),
                _buildActionButton("Update Profile", updateCredentials, Icons.person_outline),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, size: 28, color: const Color(0xFF2E7D32)),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInputField(
    TextEditingController controller,
    String hint,
    IconData icon,
    TextInputType keyboardType, {
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: const TextStyle(fontSize: 22),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 18, color: Colors.grey),
          prefixIcon: Icon(icon, size: 28, color: const Color(0xFF2E7D32)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildTimeTile(String title, String time, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 28, color: const Color(0xFF2E7D32)),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time.isEmpty ? "Tap to select time" : time,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: time.isEmpty ? Colors.grey.shade600 : const Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Color(0xFF2E7D32)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed, IconData icon) {
    return SizedBox(
      width: double.infinity,
      height: 72,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading 
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Icon(icon, size: 28, color: Colors.white),
        label: Text(
          isLoading ? "Updating..." : text,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }

  Future<void> _pickTime(bool isWake) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2E7D32),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1B5E20),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isWake) {
          wakeTime = picked.format(context);
        } else {
          sleepTime = picked.format(context);
        }
      });
    }
  }
}