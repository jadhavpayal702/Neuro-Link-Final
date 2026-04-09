import 'dart:developer' as developer;

/// Structured logging for Vocal Mode debugging (speech, TTS, navigation, AI).
class VoiceLog {
  static void speech(String message, {Object? detail}) {
    _emit('SPEECH', message, detail);
  }

  static void command(String message, {Object? detail}) {
    _emit('COMMAND', message, detail);
  }

  static void navigation(String message, {Object? detail}) {
    _emit('NAV', message, detail);
  }

  static void tts(String message, {Object? detail}) {
    _emit('TTS', message, detail);
  }

  static void ai(String message, {Object? detail}) {
    _emit('AI', message, detail);
  }

  static void listener(String message, {Object? detail}) {
    _emit('LISTENER', message, detail);
  }

  static void error(String message, {Object? error, StackTrace? stack}) {
    developer.log(
      '[Vocal][ERROR] $message',
      name: 'NeuroLink',
      error: error,
      stackTrace: stack,
    );
  }

  static void recovery(String message) {
    _emit('RECOVERY', message, null);
  }

  static void _emit(String category, String message, Object? detail) {
    final ts = DateTime.now().toIso8601String();
    final extra = detail != null ? ' | $detail' : '';
    developer.log('[$ts][Vocal][$category] $message$extra', name: 'NeuroLink');
  }
}
