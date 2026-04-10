// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class AiService {
//   AiService();

//   // ✅ Same working Gemini model
//   static const String _baseUrl =
//       'https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-lite-latest:generateContent';

//   // ✅ API KEY
//   static const String _apiKeyFromEnv = String.fromEnvironment(
//     'NEUROBOT_API_KEY',
//     defaultValue: '',
//   );

//   static const String _fallbackApiKey = "AIzaSyA75D4JOBuAddeW0lI3JrnQ8LipiggBFAk";

//   String get _apiKey =>
//       _apiKeyFromEnv.isNotEmpty ? _apiKeyFromEnv : _fallbackApiKey;

//   String? _lastRawReply;

//   bool get hasValidApiKey => _apiKey.trim().isNotEmpty;

//   /// 🧠 Deaf-friendly system instruction
//   final String _systemPrompt =
//       "You are an AI assistant for deaf users. "
//       "Use simple, short sentences. "
//       "Avoid complex words. "
//       "Be clear, friendly, and helpful. "
//       "If needed, explain step-by-step.";

//   Future<String> sendMessage(String message) async {
//     return sendWithHistory(message, const []);
//   }

//   Future<String> sendWithHistory(
//     String message,
//     List<Map<String, String>> history,
//   ) async {
//     final trimmed = message.trim();

//     if (trimmed.isEmpty) {
//       return "Please type something. I will help you.";
//     }

//     if (!hasValidApiKey) {
//       return "API key missing. Please configure it.";
//     }

//     final contents = <Map<String, dynamic>>[];

//     // ✅ ADD SYSTEM PROMPT FIRST (IMPORTANT FOR DEAF MODE)
//     contents.add({
//       'role': 'user',
//       'parts': [
//         {'text': _systemPrompt}
//       ],
//     });

//     // ✅ CHAT HISTORY
//     for (final h in history) {
//       final role = h['role'] ?? 'user';
//       final text = h['text'] ?? '';
//       if (text.isEmpty) continue;

//       contents.add({
//         'role': role == 'model' ? 'model' : 'user',
//         'parts': [
//           {'text': text}
//         ],
//       });
//     }

//     // ✅ CURRENT MESSAGE
//     contents.add({
//       'role': 'user',
//       'parts': [
//         {'text': trimmed}
//       ],
//     });

//     final uri = Uri.parse('$_baseUrl?key=$_apiKey');

//     try {
//       final response = await http.post(
//         uri,
//         headers: const {'Content-Type': 'application/json'},
//         body: jsonEncode({'contents': contents}),
//       );

//       if (response.statusCode != 200) {
//         return "Error: ${response.statusCode}";
//       }

//       final data = jsonDecode(response.body);

//       if (data['error'] != null) {
//         return "Error: ${data['error']['message']}";
//       }

//       final text =
//           data['candidates']?[0]?['content']?['parts']?[0]?['text'];

//       String reply = text?.toString().trim() ?? '';

//       if (reply.isEmpty) {
//         return _localFallback(trimmed);
//       }

//       // ✅ Make response more readable for deaf users
//       reply = _simplifyText(reply);

//       // ✅ Avoid duplicate reply
//       if (_lastRawReply == reply) {
//         return "$reply (Try asking differently)";
//       }

//       _lastRawReply = reply;
//       return reply;

//     } catch (e) {
//       return "Error: $e";
//     }
//   }

//   /// ✨ Simplify text (important for accessibility)
//   String _simplifyText(String text) {
//     // Remove long paragraphs → break into small lines
//     return text
//         .replaceAll(RegExp(r'\.\s+'), '.\n') // sentence per line
//         .replaceAll(RegExp(r'\n{2,}'), '\n') // remove extra new lines
//         .trim();
//   }

//   /// 🔁 Offline fallback
//   String _localFallback(String prompt) {
//     final lower = prompt.toLowerCase();

//     if (lower.contains('time')) {
//       final now = DateTime.now();
//       return "Time: ${now.hour}:${now.minute}";
//     }

//     if (lower.contains('help')) {
//       return "I can help with questions, learning, and daily tasks.";
//     }

//     return "AI not responding. Check internet.";
//   }
// }

import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  AiService();

  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-lite-latest:generateContent';

  static const String _apiKeyFromEnv = String.fromEnvironment(
    'NEUROBOT_API_KEY',
    defaultValue: '',
  );

  static const String _fallbackApiKey = "AIzaSyCFyZqi6oLPoaWJRFgzS0-mySxmzFZtc08";

  String get _apiKey =>
      _apiKeyFromEnv.isNotEmpty ? _apiKeyFromEnv : _fallbackApiKey;

  String? _lastRawReply;

  bool get hasValidApiKey => _apiKey.trim().isNotEmpty;

  final String _systemPrompt =
      "You are an AI assistant for deaf users. "
      "Use simple, short sentences. "
      "Be clear and helpful.";

  Future<String> sendWithHistory(
    String message,
    List<Map<String, String>> history,
  ) async {
    final trimmed = message.trim();

    if (trimmed.isEmpty) {
      return "Please type something.";
    }

    if (!hasValidApiKey) {
      return "API key missing.";
    }

    final contents = <Map<String, dynamic>>[];

    /// ✅ System instruction
    contents.add({
      'role': 'user',
      'parts': [
        {'text': _systemPrompt}
      ],
    });

    /// ✅ History
    for (final h in history) {
      final role = h['role'] ?? 'user';
      final text = h['text'] ?? '';
      if (text.isEmpty) continue;

      contents.add({
        'role': role == 'model' ? 'model' : 'user',
        'parts': [
          {'text': text}
        ],
      });
    }

    /// ✅ Current message
    contents.add({
      'role': 'user',
      'parts': [
        {'text': trimmed}
      ],
    });

    final uri = Uri.parse('$_baseUrl?key=$_apiKey');

    try {
      final response = await http.post(
        uri,
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({'contents': contents}),
      );

      if (response.statusCode != 200) {
        return "Error: ${response.statusCode}";
      }

      final data = jsonDecode(response.body);

      final text =
          data['candidates']?[0]?['content']?['parts']?[0]?['text'];

      String reply = text?.toString().trim() ?? '';

      if (reply.isEmpty) {
        return "No response from AI.";
      }

      /// ✅ Make readable
      reply = reply.replaceAll(RegExp(r'\.\s+'), '.\n');

      if (_lastRawReply == reply) {
        return "$reply (Try again)";
      }

      _lastRawReply = reply;
      return reply;

    } catch (e) {
      return "Error: $e";
    }
  }
}