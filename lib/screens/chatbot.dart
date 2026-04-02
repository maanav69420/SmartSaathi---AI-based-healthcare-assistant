import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../main.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController messageController = TextEditingController();
  final List<Map<String, String>> messages = [];

  bool isLoading = false;

  // 🎤 Speech
  final SpeechToText speech = SpeechToText();
  bool isListening = false;

  // 🔊 TTS
  final FlutterTts tts = FlutterTts();

  @override
  void initState() {
    super.initState();

    // 🤖 Greeting
    messages.add({
      "sender": "bot",
      "text": "Hello $loggedInUser 👋\nHow can I help you with your medications today?"
    });

    initTTS();
  }

  // 🔊 Initialize TTS
  void initTTS() async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.5);
  }

  // 🎤 Start Listening
  Future<void> startListening() async {
    bool available = await speech.initialize();

    if (available) {
      setState(() => isListening = true);

      speech.listen(
        onResult: (result) {
          setState(() {
            messageController.text = result.recognizedWords;
          });
        },
      );
    }
  }

  // 🛑 Stop Listening
  void stopListening() {
    speech.stop();
    setState(() => isListening = false);
  }


Future<void> sendMessage() async {
  final text = messageController.text.trim();
  if (text.isEmpty) return;

  setState(() {
    messages.add({"sender": "user", "text": text});
    isLoading = true;
  });

  messageController.clear();

  try {
    final res = await http.post(
      Uri.parse("http://10.0.2.2:5000/chatbot"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"message": text}),
    );

    print("STATUS: ${res.statusCode}");
    print("BODY: ${res.body}");

    // ❌ If server error
    if (res.statusCode != 200) {
      throw Exception("Server error: ${res.statusCode}");
    }

    final data = jsonDecode(res.body);

    String type = data['type'] ?? "general";
    String message =
        data['message'] ?? "I'm not sure I understood that 😊";

    String reply = message;

    final dynamic innerData = data['data'] ?? {};

    // 🧠 MEDICATION
    if (type == "medication") {
      String alarmName = innerData['alarm_name'] ?? "No title";

      List medsList = innerData['medication'] is List
          ? innerData['medication']
          : [];

      List timersList = innerData['timers'] is List
          ? innerData['timers']
          : [];

      String meds =
          medsList.isNotEmpty ? medsList.join(', ') : "Not specified";

      String timers =
          timersList.isNotEmpty ? timersList.join(', ') : "Not specified";

      reply += "\n\n📌 $alarmName\n💊 $meds\n⏰ $timers";
    }

    // 💧 HYDRATION
    if (type == "hydration") {
      String action = innerData['action'] ?? "";

      if (action == "add_intake") {
        try {
          await http.post(
            Uri.parse("http://10.0.2.2:5000/api/hydration/add"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "email": loggedInUser,
              "amount": 250
            }),
          );

          reply += "\n💧 I've added 250ml to your intake!";
        } catch (e) {
          reply += "\n⚠️ Couldn't update hydration right now.";
        }
      }
    }

    setState(() {
      messages.add({"sender": "bot", "text": reply});
    });

    await tts.speak(reply);

  } catch (e) {
    print("ERROR: $e");

    setState(() {
      messages.add({
        "sender": "bot",
        "text":
            "⚠️ Server not responding.\nPlease check your backend."
      });
    });

    await tts.speak("Server not responding. Please check backend.");
  } finally {
    setState(() => isLoading = false);
  }
}



  Widget buildMessage(Map<String, String> msg) {
    final isUser = msg["sender"] == "user";

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF4CAF50) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
            ),
          ],
        ),
        child: Text(
          msg["text"] ?? "",
          style: TextStyle(
            fontSize: 18,
            color: isUser ? Colors.white : Colors.black87,
          ),
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
          "Smart Assistant",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        centerTitle: true,
      ),

      body: Column(
        children: [
          // 💬 Messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return buildMessage(messages[index]);
              },
            ),
          ),

          // ⌨️ Input + Mic + Send
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              children: [
                // 🎤 Mic Button
                CircleAvatar(
                  radius: 26,
                  backgroundColor:
                      isListening ? Colors.red : const Color(0xFF4CAF50),
                  child: IconButton(
                    icon: Icon(
                      isListening ? Icons.mic : Icons.mic_none,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if (isListening) {
                        stopListening();
                      } else {
                        startListening();
                      }
                    },
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: TextField(
                    controller: messageController,
                    style: const TextStyle(fontSize: 18),
                    decoration: InputDecoration(
                      hintText: "Speak or type your request...",
                      hintStyle: const TextStyle(fontSize: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // 📤 Send button
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFF4CAF50),
                  child: IconButton(
                    icon: isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                        : const Icon(Icons.send, color: Colors.white),
                    onPressed: isLoading ? null : sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

