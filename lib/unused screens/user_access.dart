import 'package:flutter/material.dart';
import 'login.dart';
import 'register.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Elder-friendly background - soft calming color
      backgroundColor: const Color(0xFFF8F9FA),
      
      appBar: AppBar(
        title: const Text(
          "SmartSaathi",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32), // Green for trust/calm
        elevation: 0,
        centerTitle: true,
        // Remove back button for welcome screen
        automaticallyImplyLeading: false,
      ),
      
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0), // More breathing room
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Larger, friendlier app icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.people_alt_outlined,
                  size: 80,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 40),

              // Much larger, bolder welcome text
              const Text(
                "Welcome to SmartSaathi",
                style: TextStyle(
                  fontSize: 32,  // Was 20 → 32
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20), // Dark green for readability
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),

              // HUGE tappable buttons (72x72 min touch target)
              SizedBox(
                width: double.infinity,
                height: 72,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50), // Green
                    foregroundColor: Colors.white,
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 24,  // Large readable text
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text("LOGIN"),
                ),
              ),

              const SizedBox(height: 24), // Proper spacing

              SizedBox(
                width: double.infinity,
                height: 72,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF2E7D32),
                    elevation: 8,
                    side: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text("CREATE ACCOUNT"),
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}