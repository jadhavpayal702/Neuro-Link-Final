import 'package:flutter/foundation.dart';

import '../services/ai_service.dart';
import '../services/tts_service.dart';
import '../services/voice_log.dart';

class NeurobotController extends ChangeNotifier {
  NeurobotController({
    required AiService aiService,
    required TtsService ttsService,
  }) : _aiService = aiService,
       _ttsService = ttsService;

  final AiService _aiService;
  final TtsService _ttsService;
  final List<String> _chatHistory = <String>[];
  String _lastReply = '';

  List<String> get chatHistory => List<String>.unmodifiable(_chatHistory);
  String get lastReply => _lastReply;

  void clearChat() {
    _chatHistory.clear();
    VoiceLog.ai('chat cleared', detail: null);
    notifyListeners();
  }

  List<Map<String, String>> _historyForApi() {
    final out = <Map<String, String>>[];
    for (final line in _chatHistory) {
      if (line.startsWith('User: ')) {
        out.add({'role': 'user', 'text': line.replaceFirst('User: ', '')});
      } else if (line.startsWith('NeuroBot: ')) {
        out.add({'role': 'model', 'text': line.replaceFirst('NeuroBot: ', '')});
      }
    }
    if (out.length > 12) {
      return out.sublist(out.length - 12);
    }
    return out;
  }

  Future<String> replyToUser(
    String userText, {
    bool speakResponse = false,
  }) async {
    final trimmed = userText.trim();
    VoiceLog.ai('user prompt', detail: trimmed);

    final priorTurns = _historyForApi();
    final reply = await _aiService.sendWithHistory(trimmed, priorTurns);
    _chatHistory.add('User: $trimmed');
    _chatHistory.add('NeuroBot: $reply');
    _lastReply = reply;
    notifyListeners();

    if (speakResponse) {
      await _ttsService.speak(reply);
    }
    return reply;
  }
}
