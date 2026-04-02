import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import '../main.dart';
import 'hydration_alert.dart';

// ================= THEME =================
const Color elderlyPrimary = Color(0xFF2E5B85);
const Color elderlySecondary = Color(0xFF4A90A7);
const Color elderlyAccent = Color(0xFF7AB8C9);
const Color elderlyBackground = Color(0xFFF8FBFD);
const Color elderlyCard = Color(0xFFFFFFFF);
const Color elderlyTextPrimary = Color(0xFF1A1A1A);
const Color elderlyTextSecondary = Color(0xFF4A4A4A);

// ================= SCREEN =================
class HydrationScreen extends StatefulWidget {
  const HydrationScreen({super.key});

  @override
  State<HydrationScreen> createState() => _HydrationScreenState();
}

class _HydrationScreenState extends State<HydrationScreen> {
  final String baseUrl = "http://10.0.2.2:5000/api/hydration";

  late String email;
  final int weight = 70;

  int intake = 0;
  int target = 0;

  List<double> weeklyData = [0, 0, 0, 0, 0, 0, 0];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    email = loggedInUser;
    loadData();
  }

  // ================= API =================
  Future<void> loadData() async {
    setState(() => isLoading = true);
    await Future.wait([fetchTodayRecord(), fetchWeeklyData()]);
    setState(() => isLoading = false);
  }

  Future<void> fetchTodayRecord() async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/today"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "weight": weight}),
      );

      final data = jsonDecode(res.body);
      setState(() {
        intake = data["intake"] ?? 0;
        target = data["target"] ?? 0;
      });
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> addIntake(int amount) async {
    try {
      await http.post(
        Uri.parse("$baseUrl/add"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "amount": amount}),
      );
      await fetchTodayRecord();
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> resetIntake() async {
    try {
      await http.post(
        Uri.parse("$baseUrl/reset"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );
      await fetchTodayRecord();
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> fetchWeeklyData() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/weekly?email=$email"));
      final data = jsonDecode(res.body);

      setState(() {
        weeklyData = List<double>.from(
          data["weekly"].map((e) => (e as num).toDouble()),
        );
      });
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  // ================= STYLES =================
  TextStyle get _titleStyle => const TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: elderlyTextPrimary,
      );

  TextStyle get _bigNumberStyle => const TextStyle(
        fontSize: 46,
        fontWeight: FontWeight.w700,
        color: elderlyPrimary,
      );

  TextStyle get _body => const TextStyle(
        fontSize: 20,
        color: elderlyTextSecondary,
      );

  TextStyle get _buttonStyle => const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  double get progress => target == 0 ? 0 : intake / target;

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: elderlyBackground,
      appBar: AppBar(
        title: const Text(
          "Hydration Tracker",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: elderlyPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 30),
            onPressed: loadData,
          )
        ],
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(strokeWidth: 6),
                  const SizedBox(height: 20),
                  Text("Loading...", style: _body),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTodayCard(),
                    const SizedBox(height: 30),
                    _buildButtons(),
                    const SizedBox(height: 20),
                    _buildResetButton(),
                    const SizedBox(height: 40),
                    _buildChart(),
                    const SizedBox(height: 40),
                    _buildAlertButton(),
                  ],
                ),
              ),
            ),
    );
  }

  // ================= TODAY =================
  Widget _buildTodayCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Text("Today's Water Intake", style: _titleStyle),
          const SizedBox(height: 25),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 170,
                height: 170,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 14,
                  valueColor:
                      const AlwaysStoppedAnimation(elderlyAccent),
                ),
              ),
              Column(
                children: [
                  Text("$intake", style: _bigNumberStyle),
                  const Text("ml"),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text("Goal: $target ml", style: _body),
          const SizedBox(height: 10),
          Text(
            progress >= 1
                ? "You're well hydrated 👍"
                : progress > 0.7
                    ? "Almost there 💧"
                    : "Drink some water",
            style: _body,
          ),
        ],
      ),
    );
  }

  // ================= BUTTONS =================
  Widget _buildButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Add Water Intake", style: _titleStyle),
        const SizedBox(height: 15),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _waterBtn(250, "Small"),
            _waterBtn(500, "Medium"),
            _waterBtn(1000, "Large"),
          ],
        ),
      ],
    );
  }

  Widget _waterBtn(int amt, String label) {
    return SizedBox(
      width: 120,
      height: 100,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: elderlyAccent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        onPressed: () => addIntake(amt),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("+$amt", style: _bigNumberStyle.copyWith(fontSize: 26)),
            Text(label, style: _buttonStyle.copyWith(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  // ================= RESET =================
  Widget _buildResetButton() {
    return Center(
      child: TextButton(
        onPressed: () async {
          final confirm = await showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Reset Intake"),
              content: const Text("Reset today's water intake?"),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Cancel")),
                TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("Yes")),
              ],
            ),
          );

          if (confirm == true) resetIntake();
        },
        child: const Text(
          "Reset Today's Intake",
          style: TextStyle(fontSize: 18, color: Colors.red),
        ),
      ),
    );
  }

  // ================= CHART =================
  Widget _buildChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Your Weekly Progress", style: _titleStyle),
        const SizedBox(height: 20),
        Container(
          height: 250,
          padding: const EdgeInsets.all(20),
          decoration: _cardDecoration(),
          child: LineChart(
            LineChartData(
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              lineBarsData: [
                LineChartBarData(
                  isCurved: true,
                  barWidth: 5,
                  color: elderlyAccent,
                  spots: List.generate(
                    weeklyData.length,
                    (i) => FlSpot(i.toDouble(), weeklyData[i]),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ================= ALERT =================
  Widget _buildAlertButton() {
    return SizedBox(
      width: double.infinity,
      height: 65,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: elderlySecondary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const HydrationAlertScreen(),
            ),
          );
        },
        icon: const Icon(Icons.notifications, size: 28),
        label: Text("Manage Reminders", style: _buttonStyle),
      ),
    );
  }

  // ================= CARD =================
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: elderlyCard,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: elderlyPrimary.withOpacity(0.1),
          blurRadius: 15,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}