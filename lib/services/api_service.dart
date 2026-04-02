import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://10.0.2.2:5000";

  static Future<String?> login(String name, String password) async {
    final res = await http.post(
      Uri.parse("$baseUrl/api/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "password": password}),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body)["user_id"];
    }
    return null;
  }

  static Future<String?> register(
      String name, int age, String wake, String sleep, String password) async {
    final res = await http.post(
      Uri.parse("$baseUrl/api/auth/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "age": age,
        "wake_up": wake,
        "sleep_time": sleep,
        "password": password
      }),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body)["user_id"];
    }
    return null;
  }
}