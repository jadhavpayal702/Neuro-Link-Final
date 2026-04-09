import 'voice_log.dart';

/// Flexible keyword / substring intent recognition for Vocal Mode.
class CommandService {
  static const String unrecognized = 'unrecognized';

  /// Returns a normalized intent token: learn, communicate, play, control, community,
  /// back, home, navigate, stop navigation, wake neurobot, help, continue,
  /// memory game, quiz game, riddle game, repeat, emergency, clear chat, pause listening.
  static String detectIntent(String raw) {
    final original = raw.toLowerCase().trim();
    if (original.isEmpty) return unrecognized;

    if (_containsAny(original, ['stop navigation', 'cancel navigation', 'end navigation'])) {
      return 'stop navigation';
    }
    if (_containsAny(original, ['memory game', 'start memory', 'play memory'])) {
      return 'memory game';
    }
    if (_containsAny(original, ['quiz game', 'start quiz', 'trivia'])) {
      return 'quiz game';
    }
    if (_containsAny(original, ['riddle', 'riddle game', 'riddles'])) {
      return 'riddle game';
    }
    if (_containsAny(original, ['clear chat', 'clear conversation', 'reset chat'])) {
      return 'clear chat';
    }
    if (_containsAny(original, ['repeat', 'say again', 'repeat that'])) {
      return 'repeat';
    }
    if (_containsAny(original, ['emergency', 'help me emergency', 'sos'])) {
      return 'emergency';
    }
    if (_containsAny(original, ['pause listening', 'stop listening', 'mute mic'])) {
      return 'pause listening';
    }
    if (_containsAny(original, ['resume listening', 'start listening', 'listen again'])) {
      return 'resume listening';
    }

    // Wake NeuroBot — many phrasings
    if (RegExp(r'\b(?:hello|hey|hi)?\s*neuro\s*bot\b', caseSensitive: false).hasMatch(original)) {
      return 'wake neurobot';
    }
    if (_containsAny(original, ['hello neurobot', 'hey neurobot', 'hi neurobot', 'okay neurobot'])) {
      return 'wake neurobot';
    }

    if (_matchesNav(original, ['home', 'main menu', 'go home', 'open home', 'vocal home'])) {
      return 'home';
    }
    if (_matchesNav(original, ['back', 'go back', 'previous', 'return', 'last screen'])) {
      return 'back';
    }
    if (_matchesNav(original, [
      'learn',
      'learning',
      'lesson',
      'course',
      'study',
      'open learn',
      'go to learn',
      'start learning',
      'navigate to learn',
    ])) {
      return 'learn';
    }
    if (_matchesNav(original, [
      'communicate',
      'communication',
      'chat',
      'talk',
      'open communicate',
      'go to communicate',
      'voice chat',
    ])) {
      return 'communicate';
    }
    if (_matchesNav(original, [
      'play',
      'games',
      'game',
      'open play',
      'go to play',
      'start games',
    ])) {
      return 'play';
    }
    if (_matchesNav(original, ['control', 'smart control', 'iot', 'devices', 'open control'])) {
      return 'control';
    }
    if (_matchesNav(original, ['community', 'rooms', 'open community'])) {
      return 'community';
    }
    if (_matchesNav(original, ['navigate', 'navigation', 'directions', 'take me to', 'route to'])) {
      return 'navigate';
    }
    if (_matchesNav(original, ['help', 'options', 'what can i say', 'commands'])) {
      return 'help';
    }
    if (_containsAny(original, ['continue', 'next step', 'next lesson', 'keep going'])) {
      return 'continue';
    }
    if (_containsAny(original, ['yes', 'yeah', 'sure', 'ok', 'okay']) && original.length < 20) {
      return 'yes';
    }
    if (_containsAny(original, ['no', 'nope', 'not now', 'stop']) && original.length < 20) {
      return 'no';
    }

    VoiceLog.command('No primary intent matched, returning raw for downstream handling', detail: original);
    return original;
  }

  static bool _containsAny(String haystack, List<String> needles) {
    for (final n in needles) {
      if (haystack.contains(n)) return true;
    }
    return false;
  }

  static bool _matchesNav(String lower, List<String> tokens) {
    for (final t in tokens) {
      if (lower.contains(t)) return true;
    }
    return false;
  }
}
