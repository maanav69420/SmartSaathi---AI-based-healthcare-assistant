import 'package:flutter/material.dart';
import '../main.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ✅ This forces rebuild whenever screen is revisited
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Calming background
      backgroundColor: const Color(0xFFF8F9FA),
      
      appBar: AppBar(
        title: const Text(
          "My Dashboard",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        centerTitle: true,
        // Profile indicator
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20,
              child: Text(
                loggedInUser.isNotEmpty 
                    ? loggedInUser[0].toUpperCase() 
                    : 'U',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ),
          ),
        ],
      ),
      
      body: SingleChildScrollView(   // ✅ FIXED OVERFLOW
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Personal welcome with large friendly text
              Container(
                width: double.infinity,
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
                    const Icon(
                      Icons.account_circle,
                      size: 80,
                      color: Color(0xFF2E7D32),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Welcome",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loggedInName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1B5E20),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              const SizedBox(height: 24),

// ⚙️ SETTINGS SCREEN
SizedBox(
  width: double.infinity,
  height: 80,
  child: ElevatedButton.icon(
    onPressed: () async {
  await Navigator.pushNamed(context, '/settings');
  setState(() {}); 
},
    icon: const Icon(Icons.settings, size: 32, color: Colors.white),
    label: const Text(
      "SETTINGS",
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF757575),
      foregroundColor: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  ),
),

              

              const SizedBox(height: 24),

              // ADD MEDICATION
              SizedBox(
                width: double.infinity,
                height: 80,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/addMed'),
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
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // VIEW MEDICATIONS
              SizedBox(
                width: double.infinity,
                height: 80,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/viewMed'),
                  icon: const Icon(Icons.list_alt,
                      size: 32, color: Color(0xFF2E7D32)),
                  label: const Text(
                    "VIEW MEDICATIONS",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF2E7D32),
                    elevation: 8,
                    side: const BorderSide(
                        color: Color(0xFF2E7D32), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

// 💧 HYDRATION SCREEN
SizedBox(
  width: double.infinity,
  height: 80,
  child: ElevatedButton.icon(
    onPressed: () => Navigator.pushNamed(context, '/hydration'),
    icon: const Icon(Icons.water_drop, size: 32, color: Colors.white),
    label: const Text(
      "HYDRATION TRACKER",
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF29B6F6),
      foregroundColor: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  ),
),

// 🤖 Chatbot Button
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 80,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/chatbot'),
                  icon: const Icon(Icons.smart_toy, size: 32, color: Colors.white),
                  label: const Text(
                    "SMART ASSISTANT",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}