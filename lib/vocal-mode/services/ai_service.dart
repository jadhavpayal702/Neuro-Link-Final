import 'dart:convert';

import 'package:http/http.dart' as http;

import 'voice_log.dart';

/// NeuroBot / Gemini integration with logging, optional API key, and de-duplication hints.
class AiService {
  AiService();

  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  /// Set at build time: `--dart-define=NEUROBOT_API_KEY=your_key`
  static const String _apiKeyFromEnv = String.fromEnvironment(
    'NEUROBOT_API_KEY',
    defaultValue: '',
  );

  String? _lastRawReply;
  int _requestCounter = 0;

  bool get hasValidApiKey => _apiKeyFromEnv.trim().isNotEmpty;

  Future<String> sendMessageToAI(String message) async {
    return sendWithHistory(message, const <Map<String, String>>[]);
  }

  /// [history] entries: `{'role': 'user'|'model', 'text': '...'}` — last turns for context.
  Future<String> sendWithHistory(
    String message,
    List<Map<String, String>> history,
  ) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty) {
      return 'Please say something and I will help you.';
    }

    if (!hasValidApiKey) {
      VoiceLog.ai('No API key configured', detail: 'NEUROBOT_API_KEY empty');
      return 'API key invalid. Please update your NeuroBot API key in settings. '
          'Developers: pass --dart-define=NEUROBOT_API_KEY=your_key when building.';
    }

    _requestCounter++;
    final uniqueHint =
        '[session turn $_requestCounter at ${DateTime.now().toIso8601String()}] ';
    final userPayload = uniqueHint + trimmed;

    final contents = <Map<String, dynamic>>[];
    for (final h in history) {
      final role = h['role'] ?? 'user';
      final text = h['text'] ?? '';
      if (text.isEmpty) continue;
      contents.add({
        'role': role == 'model' ? 'model' : 'user',
        'parts': [
          {'text': text},
        ],
      });
    }
    contents.add({
      'role': 'user',
      'parts': [
        {
          'text':
              'You are NeuroBot, a concise assistant for blind users. '
              'Answer clearly in short paragraphs. Vary wording; do not repeat prior replies verbatim.\n'
              '$userPayload',
        },
      ],
    });

    final uri = Uri.parse('$_baseUrl?key=$_apiKeyFromEnv');
    try {
      VoiceLog.ai('POST generateContent', detail: 'historyLen=${history.length}');
      final response = await http.post(
        uri,
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({'contents': contents}),
      );

      VoiceLog.ai(
        'response status=${response.statusCode}',
        detail: response.body.length > 400 ? '${response.body.substring(0, 400)}...' : response.body,
      );

      if (response.statusCode == 401 || response.statusCode == 403) {
        return 'API key invalid. Please update your NeuroBot API key in settings.';
      }

      if (response.statusCode == 429) {
        return 'The service is busy. Please wait a moment and try again.';
      }

      if (response.statusCode != 200) {
        return _localFallback(trimmed);
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
      final reply = text?.toString().trim() ?? '';
      if (reply.isEmpty) {
        VoiceLog.ai('Empty candidate text', detail: null);
        return _localFallback(trimmed);
      }

      if (_lastRawReply != null && _lastRawReply == reply) {
        VoiceLog.ai('Duplicate reply detected — appending variation hint', detail: null);
        _lastRawReply = reply;
        return '$reply — Tell me if you want more detail on a specific part.';
      }
      _lastRawReply = reply;
      return reply;
    } catch (e, st) {
      VoiceLog.error('AI request failed', error: e, stack: st);
      return _localFallback(trimmed);
    }
  }

  String _localFallback(String prompt) {
    final lower = prompt.toLowerCase();
    if (lower.contains('time')) {
      final now = DateTime.now();
      final h = now.hour % 12 == 0 ? 12 : now.hour % 12;
      return 'It is $h:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}.';
    }
    if (lower.contains('help')) {
      return 'You can say learn, communicate, play, control, back, or home. '
          'Say hello NeuroBot to chat with me.';
    }
    return 'I could not reach the AI service. Please check your connection and API key, then try again.';
  }
}
