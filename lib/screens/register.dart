import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // ✅ Controllers
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final ageController = TextEditingController();
  final weightController = TextEditingController();
  final passwordController = TextEditingController();

  // ✅ Time variables
  String wakeTime = "";
  String sleepTime = "";

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    // rebuild UI when typing
    usernameController.addListener(() => setState(() {}));
    emailController.addListener(() => setState(() {}));
    ageController.addListener(() => setState(() {}));
    weightController.addListener(() => setState(() {}));
    passwordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    ageController.dispose();
    weightController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ✅ Smart validation
  bool _isFormValid() {
    return usernameController.text.trim().isNotEmpty &&
        emailController.text.trim().contains('@') &&
        ageController.text.trim().isNotEmpty &&
        int.tryParse(ageController.text.trim()) != null &&
        int.tryParse(ageController.text.trim())! > 0 &&
        weightController.text.trim().isNotEmpty &&
        int.tryParse(weightController.text.trim()) != null &&
        int.tryParse(weightController.text.trim())! > 0 &&
        passwordController.text.trim().length >= 4 &&
        wakeTime.isNotEmpty &&
        sleepTime.isNotEmpty;
  }

  // ✅ Register API with error handling
  void register() async {
    if (!_isFormValid()) {
      _showError("Please fill all fields correctly");
      return;
    }

    setState(() => isLoading = true);

    try {
      final res = await http.post(
        Uri.parse("http://10.0.2.2:5000/auth/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": usernameController.text.trim(),
          "email": emailController.text.trim(),
          "age": int.parse(ageController.text.trim()),
          "routine": [wakeTime, sleepTime],
          "weight": int.parse(weightController.text.trim()),
          "password": passwordController.text.trim()
        }),
      );

      if (res.statusCode == 200) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "✅ Account created successfully!",
                style: TextStyle(fontSize: 18),
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
          Navigator.pop(context);
        }
      } else {
        _showError("Registration failed. Please try again.");
      }
    } catch (e) {
      _showError("Connection error. Please check your internet.");
    } finally {
      if (context.mounted) {
        setState(() => isLoading = false);
      }
    }
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

  // ✅ Elder-friendly time picker
  Future<void> pickTime(bool isWake) async {
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
      final formattedTime = picked.format(context);
      setState(() {
        if (isWake) {
          wakeTime = formattedTime;
        } else {
          sleepTime = formattedTime;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isValid = _isFormValid();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Create Account",
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
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            // Hero illustration
            Container(
              width: 160,
              height: 160,
              margin: const EdgeInsets.only(bottom: 40),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person_add,
                size: 100,
                color: Color(0xFF2E7D32),
              ),
            ),

            // Title
            const Text(
              "Join SmartSaathi",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Set up your profile for personalized medication reminders",
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // USERNAME ✅ Elder-friendly
            _buildInputField(
              controller: usernameController,
              icon: Icons.person_outline,
              label: "Full Name",
              hint: "e.g., John Smith",
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: 24),

            // EMAIL ✅ Elder-friendly
            _buildInputField(
              controller: emailController,
              icon: Icons.email_outlined,
              label: "Email Address",
              hint: "e.g., john@example.com",
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),

            // AGE ✅ Elder-friendly
            _buildInputField(
              controller: ageController,
              icon: Icons.cake_outlined,
              label: "Age",
              hint: "e.g., 65",
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            // WEIGHT ✅ Elder-friendly
            _buildInputField(
              controller: weightController,
              icon: Icons.fitness_center_outlined,
              label: "Weight (kg)",
              hint: "e.g., 70",
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            // PASSWORD ✅ Elder-friendly
            _buildInputField(
              controller: passwordController,
              icon: Icons.lock_outline,
              label: "Password",
              hint: "Minimum 4 characters",
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,
            ),
            const SizedBox(height: 32),

            // WAKE TIME ✅ Elder-friendly
            _buildTimeTile(
              title: "Wake Up Time",
              time: wakeTime.isEmpty ? "Tap to select" : "Wake: $wakeTime",
              icon: Icons.wb_sunny_outlined,
              onTap: () => pickTime(true),
            ),
            const SizedBox(height: 24),

            // SLEEP TIME ✅ Elder-friendly
            _buildTimeTile(
              title: "Sleep Time",
              time: sleepTime.isEmpty ? "Tap to select" : "Sleep: $sleepTime",
              icon: Icons.nights_stay_outlined,
              onTap: () => pickTime(false),
            ),
            const SizedBox(height: 48),

            // REGISTER BUTTON ✅ HUGE & Elder-friendly
            SizedBox(
              width: double.infinity,
              height: 80,
              child: ElevatedButton(
                onPressed: isLoading ? null : register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isValid && !isLoading 
                      ? const Color(0xFF4CAF50) 
                      : Colors.grey.shade400,
                  foregroundColor: Colors.white,
                  elevation: 12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 16),
                          Text("Creating Account..."),
                        ],
                      )
                    : const Text("CREATE ACCOUNT"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Reusable elder-friendly input field
  Widget _buildInputField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: const TextStyle(fontSize: 22),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2E7D32),
          ),
          hintText: hint,
          hintStyle: TextStyle(fontSize: 18, color: Colors.grey),
          prefixIcon: Icon(icon, size: 32, color: const Color(0xFF2E7D32)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        ),
        textInputAction: TextInputAction.next,
      ),
    );
  }

  // ✅ Reusable elder-friendly time tile
  Widget _buildTimeTile({
    required String title,
    required String time,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, size: 32, color: const Color(0xFF2E7D32)),
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
                        time,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: time == "Tap to select" 
                              ? Colors.grey.shade600 
                              : const Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFF2E7D32),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}