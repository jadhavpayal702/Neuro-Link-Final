import 'package:flutter_tts/flutter_tts.dart';

import 'voice_log.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();
  String _lastSpoken = '';

  String get lastSpoken => _lastSpoken;

  Future<void> initialize() async {
    await _tts.setLanguage('en-US');
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.awaitSpeakCompletion(true);
    _tts.setCompletionHandler(() {
      VoiceLog.tts('completion', detail: 'utterance finished');
    });
    _tts.setErrorHandler((msg) {
      VoiceLog.error('TTS error', error: msg);
    });
  }

  Future<void> speak(String text, {bool interrupt = true}) async {
    if (text.trim().isEmpty) return;
    _lastSpoken = text;
    VoiceLog.tts('speak start', detail: text.length > 120 ? '${text.substring(0, 120)}...' : text);
    if (interrupt) {
      await _tts.stop();
    }
    await _tts.speak(text);
    VoiceLog.tts('speak end', detail: null);
  }

  /// Speaks multiple sentences with a short pause between each (accessibility clarity).
  Future<void> speakWithPauses(List<String> sentences, {int pauseMs = 260}) async {
    for (var i = 0; i < sentences.length; i++) {
      final s = sentences[i].trim();
      if (s.isEmpty) continue;
      await speak(s, interrupt: i == 0);
      if (i < sentences.length - 1) {
        await Future<void>.delayed(Duration(milliseconds: pauseMs));
      }
    }
  }

  Future<void> repeatLast() async {
    if (_lastSpoken.isEmpty) return;
    await speak(_lastSpoken);
  }

  Future<void> stop() => _tts.stop();
}
