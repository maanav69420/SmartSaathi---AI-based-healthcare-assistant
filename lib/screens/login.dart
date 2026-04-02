import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isPasswordVisible = false;

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    usernameController.addListener(() => setState(() {}));
    emailController.addListener(() => setState(() {}));
    passwordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool _isFormValid() {
    return usernameController.text.trim().isNotEmpty &&
           emailController.text.trim().contains('@') &&
           passwordController.text.trim().isNotEmpty;
  }

  void login() async {
    if (!_isFormValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please fill all fields correctly",
            style: TextStyle(fontSize: 18),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Signing in...",
          style: TextStyle(fontSize: 18),
        ),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 1),
      ),
    );

    final res = await http.post(
      Uri.parse("http://10.0.2.2:5000/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": usernameController.text.trim(),
        "email": emailController.text.trim(),
        "password": passwordController.text.trim()
      }),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      loggedInUser = data['user']['email'];
      loggedInName = data['user']['name']; 
      if (context.mounted) {
        Navigator.pushNamed(context, '/home');
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "Login Failed - Please check your details",
              style: TextStyle(fontSize: 18),
            ),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Welcome Back",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
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
                Icons.lock_open,
                size: 100,
                color: Color(0xFF2E7D32),
              ),
            ),

            // Title
            const Text(
              "Sign In to SmartSaathi",
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
              "Enter your details to access your medications",
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            /// ✅ USERNAME FIELD - Elder-friendly
            Container(
              margin: const EdgeInsets.only(bottom: 24),
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
                controller: usernameController,
                style: const TextStyle(fontSize: 22),
                decoration: InputDecoration(
                  labelText: "Full Name",
                  labelStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2E7D32),
                  ),
                  hintText: "e.g., John Smith",
                  hintStyle: TextStyle(fontSize: 18, color: Colors.grey),
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    size: 32,
                    color: Color(0xFF2E7D32),
                  ),
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
            ),

            /// ✅ EMAIL FIELD - Elder-friendly
            Container(
              margin: const EdgeInsets.only(bottom: 24),
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
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(fontSize: 22),
                decoration: InputDecoration(
                  labelText: "Email Address",
                  labelStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2E7D32),
                  ),
                  hintText: "e.g., john@example.com",
                  hintStyle: TextStyle(fontSize: 18, color: Colors.grey),
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    size: 32,
                    color: Color(0xFF2E7D32),
                  ),
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
            ),

            /// ✅ PASSWORD FIELD - Elder-friendly
            Container(
              margin: const EdgeInsets.only(bottom: 48),
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
                controller: passwordController,
                obscureText: !isPasswordVisible,
                style: const TextStyle(fontSize: 22),
                decoration: InputDecoration(
                  labelText: "Password",
                  labelStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2E7D32),
                  ),
                  hintText: "Enter your password",
                  hintStyle: TextStyle(fontSize: 18, color: Colors.grey),
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    size: 32,
                    color: Color(0xFF2E7D32),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                      size: 28,
                      color: const Color(0xFF2E7D32),
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  ),
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
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => login(),
              ),
            ),

            /// ✅ HUGE LOGIN BUTTON
            SizedBox(
              width: double.infinity,
              height: 80,
              child: ElevatedButton(
                onPressed: _isFormValid() ? login : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFormValid() 
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
                child: const Text("LOGIN"),
              ),
            ),

            const SizedBox(height: 32),

            /// ✅ CREATE ACCOUNT BUTTON (matching style)
            SizedBox(
              width: double.infinity,
              height: 80,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
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
                child: const Text("CREATE ACCOUNT"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}