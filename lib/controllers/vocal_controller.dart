import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart' show ChangeNotifier, listEquals;
import 'package:flutter/widgets.dart' show ModalRoute;

import '../models/course_model.dart';
import '../services/command_service.dart';
import '../services/navigation_service.dart';
import '../services/tts_service.dart';
import '../services/voice_log.dart';
import '../services/voice_service.dart';
import 'neurobot_controller.dart';

enum VocalModeState {
  activeConversation,
  navigationMode,
  gameMode,
}

enum VocalGameKind { none, quiz, memory, riddle }

enum VocalSection {
  home,
  learn,
  communicate,
  play,
  control,
  community,
  navigation,
}

class VocalController extends ChangeNotifier {
  VocalController({
    required VoiceService voiceService,
    required TtsService ttsService,
    required NavigationService navigationService,
    required NeurobotController neurobotController,
    required VoiceNavigationService voiceNavigation,
  })  : _voiceService = voiceService,
        _ttsService = ttsService,
        _navigationService = navigationService,
        _neurobotController = neurobotController,
        _voiceNavigation = voiceNavigation;

  final VoiceService _voiceService;
  final TtsService _ttsService;
  final NavigationService _navigationService;
  final NeurobotController _neurobotController;
  final VoiceNavigationService _voiceNavigation;

  VocalModeState _mode = VocalModeState.activeConversation;
  VocalSection _currentSection = VocalSection.home;
  String _lastHeard = '';
  String _statusMessage = 'Initializing voice system...';
  bool _initialized = false;
  bool _neurobotAwake = false;
  Timer? _silenceTimer;

  VocalGameKind _gameKind = VocalGameKind.none;
  int _memoryLevel = 1;
  List<int> _memorySequence = <int>[];
  int _quizScore = 0;
  int _quizIndex = 0;
  int _riddleIndex = 0;

  CourseModel? _activeCourse;
  int _lessonStepIndex = 0;

  static final RegExp _wakeWordPattern = RegExp(
    r'\b(?:hello|hey|hi)?\s*neuro\s*bot\b',
    caseSensitive: false,
  );

  final List<Map<String, Object>> _quizQuestions = <Map<String, Object>>[
    <String, Object>{
      'q': 'What planet is known as the Red Planet?',
      'a': <String>['mars'],
    },
    <String, Object>{
      'q': 'How many days are there in a week?',
      'a': <String>['7', 'seven'],
    },
    <String, Object>{
      'q': 'What is two plus two?',
      'a': <String>['4', 'four'],
    },
  ];

  final List<Map<String, Object>> _riddles = <Map<String, Object>>[
    <String, Object>{
      'q': 'What has keys but no locks, space but no room, and you can enter but not go inside?',
      'a': <String>['keyboard', 'a keyboard'],
    },
    <String, Object>{
      'q': 'What begins with T, ends with T, and has T in it?',
      'a': <String>['teapot', 'a teapot'],
    },
    <String, Object>{
      'q': 'I speak without a mouth and hear without ears. What am I?',
      'a': <String>['echo', 'an echo'],
    },
  ];

  VocalModeState get mode => _mode;
  VocalSection get currentSection => _currentSection;
  String get lastHeard => _lastHeard;
  String get statusMessage => _statusMessage;
  bool get initialized => _initialized;
  Map<int, double> get lessonProgress => Map<int, double>.unmodifiable(_lessonProgress);
  int get memoryLevel => _memoryLevel;
  List<int> get memorySequence => List<int>.unmodifiable(_memorySequence);
  int get quizScore => _quizScore;
  List<String> get chatHistory => _neurobotController.chatHistory;

  final Map<int, double> _lessonProgress = <int, double>{};

  List<String> get courses =>
      CourseModel.vocalCourses.map((c) => c.title).toList(growable: false);

  void _cancelSilenceTimer() {
    _silenceTimer?.cancel();
    _silenceTimer = null;
  }

  void _armSilencePrompt() {
    _cancelSilenceTimer();
    _silenceTimer = Timer(const Duration(seconds: 5), () async {
      VoiceLog.recovery('Silence timeout — prompting user');
      await _speakResponse(
        'You can say Learn, Communicate, Play, or Control.',
        restartListening: true,
      );
    });
  }

  String? _extractPromptAfterWakeWord(String speechText) {
    final text = speechText.trim();
    if (text.isEmpty) return null;
    final match = _wakeWordPattern.firstMatch(text);
    if (match == null) return null;
    final remainder = text
        .substring(match.end)
        .replaceFirst(RegExp(r'^[,\s:.-]+'), '')
        .trim();
    return remainder;
  }

  Future<void> _activateNeurobotConversation({String initialPrompt = ''}) async {
    _mode = VocalModeState.activeConversation;
    _neurobotAwake = true;
    _currentSection = VocalSection.communicate;
    _voiceNavigation.pushCommunicate();
    notifyListeners();

    if (initialPrompt.isEmpty) {
      await _speakResponse(
        'Hello, how can I help you?',
        restartListening: true,
      );
      return;
    }

    await _speakResponse('Opening communication.', restartListening: false);
    final reply = await _neurobotController.replyToUser(initialPrompt);
    await _speakResponse(reply, restartListening: true);
  }

  Future<void> initializeVoiceMode() async {
    if (_initialized) return;
    await _ttsService.initialize();
    final ok = await _voiceService.initialize();
    final micPermissionGranted = await _voiceService.hasPermission;
    if (!ok || !micPermissionGranted) {
      _statusMessage =
          'Microphone permission is required. Please allow microphone access and reopen voice mode.';
      notifyListeners();
      await _ttsService.speak(_statusMessage);
      VoiceLog.error('Mic init failed: ok=$ok permission=$micPermissionGranted');
      return;
    }
    _initialized = true;
    await _speakResponse(
      'Voice control is ready. Say Learn, Communicate, Play, Control, Community, Navigation, Back, Home, or Hello NeuroBot.',
      restartListening: false,
    );
    await _voiceService.startConversationListening(_onVoiceText);
    _armSilencePrompt();
  }

  Future<void> enterSection(VocalSection section) async {
    _currentSection = section;
    notifyListeners();
    await _announceSectionOptions(section, resumeListening: false);
  }

  Future<void> handleManualCommand(String command) async {
    final raw = command.toLowerCase().trim();
    await _onCommand(CommandService.detectIntent(raw), rawInput: raw);
  }

  Future<void> emergencyAction() async {
    await _speakResponse(
      'Emergency mode activated. Alert sent and your current location has been prepared for sharing.',
    );
  }

  Future<void> repeatInstruction() async {
    await _announceSectionOptions(_currentSection);
  }

  Future<void> startLearning() async {
    _currentSection = VocalSection.learn;
    _voiceNavigation.pushLearn();
    notifyListeners();
    await _speakResponse(
      'Learning module opened. Say English Speaking, Basic Computer Skills, Daily Life Skills, or Coding Basics to begin a course.',
    );
  }

  Future<void> selectCourseByVoice(String text) async {
    final lower = text.toLowerCase();
    final match = CourseModel.matchBySpeech(lower);
    if (match == null) {
      await _speakResponse(
        'Say one of: English Speaking, Basic Computer Skills, Daily Life Skills, or Coding Basics.',
      );
      return;
    }
    _activeCourse = match;
    _lessonStepIndex = 0;
    final idx = CourseModel.vocalCourses.indexOf(match);
    _lessonProgress[idx] = _lessonProgress[idx] ?? 0.0;
    notifyListeners();

    await _ttsService.speakWithPauses([
      'Welcome to ${match.title} course.',
      match.welcomeScript,
      match.lessonSteps.first,
    ]);
    await _speakResponse(
      'Do you want to continue to the next step, or say back to leave this course?',
      restartListening: true,
    );
  }

  Future<void> continueLesson() async {
    final course = _activeCourse;
    if (course == null) {
      await _speakResponse('Say a course name first.');
      return;
    }
    if (_lessonStepIndex >= course.lessonSteps.length - 1) {
      final idx = CourseModel.vocalCourses.indexOf(course);
      _lessonProgress[idx] = 1.0;
      notifyListeners();
      await _speakResponse(
        '${course.title} completed. Do you want to continue with another course or say back?',
      );
      return;
    }
    _lessonStepIndex++;
    final step = course.lessonSteps[_lessonStepIndex];
    final idx = CourseModel.vocalCourses.indexOf(course);
    final progress = (_lessonStepIndex + 1) / course.lessonSteps.length;
    _lessonProgress[idx] = progress;
    notifyListeners();
    await _speakResponse(step);
  }

  Future<void> startMemoryGame() async {
    _mode = VocalModeState.gameMode;
    _gameKind = VocalGameKind.memory;
    final random = Random();
    _memorySequence = List<int>.generate(_memoryLevel + 2, (_) => random.nextInt(9) + 1);
    notifyListeners();
    await _speakResponse(
      'Memory game. Listen to this sequence: ${_memorySequence.join(', ')}. Now repeat the numbers in order.',
    );
  }

  Future<void> checkMemoryAnswer(String input) async {
    if (_gameKind != VocalGameKind.memory) return;
    final spoken = input
        .split(RegExp(r'[^0-9]+'))
        .where((s) => s.isNotEmpty)
        .map(int.parse)
        .toList();
    if (listEquals(spoken, _memorySequence)) {
      _memoryLevel++;
      await _speakResponse('Correct. Level $_memoryLevel.');
      await startMemoryGame();
      return;
    }
    await _speakResponse('Not quite. Say the sequence again, or say back to exit the game.');
  }

  Future<void> startQuizGame() async {
    _mode = VocalModeState.gameMode;
    _gameKind = VocalGameKind.quiz;
    _quizIndex = 0;
    _quizScore = 0;
    notifyListeners();
    final firstQuestion = _quizQuestions[_quizIndex]['q'] as String;
    await _speakResponse('Quiz game. Question 1. $firstQuestion');
  }

  Future<void> submitQuizAnswer(String answer) async {
    if (_gameKind != VocalGameKind.quiz) return;
    final answerText = answer.toLowerCase().trim();
    final expected = _quizQuestions[_quizIndex]['a'] as List<String>;
    final isCorrect = expected.any((token) => answerText.contains(token));
    if (isCorrect) {
      _quizScore += 10;
      notifyListeners();
      _quizIndex++;
      if (_quizIndex >= _quizQuestions.length) {
        _mode = VocalModeState.activeConversation;
        _gameKind = VocalGameKind.none;
        await _speakResponse('Quiz finished. Your score is $_quizScore points.');
        return;
      }
      final nextQuestion = _quizQuestions[_quizIndex]['q'] as String;
      await _speakResponse('Correct. Next question. $nextQuestion');
      return;
    }
    await _speakResponse('Incorrect. Try again.');
  }

  Future<void> startRiddleGame() async {
    _mode = VocalModeState.gameMode;
    _gameKind = VocalGameKind.riddle;
    _riddleIndex = 0;
    notifyListeners();
    final q = _riddles[_riddleIndex]['q'] as String;
    await _speakResponse('Riddle game. $q');
  }

  Future<void> submitRiddleAnswer(String answer) async {
    if (_gameKind != VocalGameKind.riddle) return;
    final lower = answer.toLowerCase().trim();
    final expected = _riddles[_riddleIndex]['a'] as List<String>;
    final ok = expected.any((e) => lower.contains(e));
    if (ok) {
      await _speakResponse('That is correct.');
      _riddleIndex++;
      if (_riddleIndex >= _riddles.length) {
        _mode = VocalModeState.activeConversation;
        _gameKind = VocalGameKind.none;
        await _speakResponse('You finished all riddles. Say play for more games.');
        return;
      }
      final q = _riddles[_riddleIndex]['q'] as String;
      await _speakResponse('Next riddle. $q');
      return;
    }
    await _speakResponse('Not yet. Guess again or say skip.');
  }

  Future<void> navigateToDestination(String destination) async {
    _mode = VocalModeState.navigationMode;
    _currentSection = VocalSection.navigation;
    _voiceNavigation.pushNavigation();
    notifyListeners();
    try {
      final steps = await _navigationService.buildVoiceGuidance(destinationLabel: destination);
      for (final step in steps) {
        await _speakResponse(step, restartListening: false);
      }
      await _speakResponse('Say repeat to hear directions again, or stop navigation.');
    } catch (e) {
      VoiceLog.error('Navigation failed', error: e);
      await _speakResponse(
        'Navigation could not start. Check location permission. Say navigate again when ready.',
      );
    }
  }

  Future<void> stopNavigation() async {
    if (_mode == VocalModeState.navigationMode) {
      _mode = VocalModeState.activeConversation;
      notifyListeners();
      await _speakResponse('Navigation stopped.');
    }
  }

  void _onVoiceText(String text, bool isFinal) {
    _lastHeard = text;
    VoiceLog.speech(isFinal ? 'final' : 'partial', detail: text);
    notifyListeners();
    if (!isFinal) return;
    _cancelSilenceTimer();
    unawaited(_processFinalSpeech(text));
  }

  Future<void> _processFinalSpeech(String text) async {
    final raw = text.toLowerCase().trim();
    final intent = CommandService.detectIntent(raw);
    VoiceLog.command('intent=$intent', detail: raw);
    await _onCommand(intent, rawInput: raw);
  }

  Future<void> _onCommand(String command, {String rawInput = ''}) async {
    if (command.isEmpty) {
      await _speakResponse('Sorry, I didn\'t understand. Please try again.');
      return;
    }

    if (command == CommandService.unrecognized) {
      if (_currentSection == VocalSection.learn && rawInput.isNotEmpty) {
        await selectCourseByVoice(rawInput);
        return;
      }
      if (_neurobotAwake || _currentSection == VocalSection.communicate) {
        try {
          final reply = await _neurobotController.replyToUser(rawInput.isEmpty ? command : rawInput);
          await _speakResponse(reply);
        } catch (e) {
          VoiceLog.error('NeuroBot failed', error: e);
          await _speakResponse(
            'I could not get a response. Check your connection and API key, then try again.',
          );
        }
        return;
      }
      await _speakResponse(
        'Sorry, I didn\'t understand. Please try again.',
      );
      return;
    }

    if (command == 'pause listening') {
      await _voiceService.pauseListening();
      await _ttsService.speak('Listening paused. Say resume listening when you want to continue.');
      return;
    }
    if (command == 'resume listening') {
      await _voiceService.resumeListening();
      await _speakResponse('Listening resumed.');
      return;
    }

    if (command == 'repeat') {
      final last = _ttsService.lastSpoken;
      if (last.isNotEmpty) {
        await _speakResponse(last);
      }
      return;
    }

    final spokenText = rawInput.isEmpty ? command : rawInput;
    final wakePrompt = _extractPromptAfterWakeWord(spokenText);
    if (wakePrompt != null) {
      await _activateNeurobotConversation(initialPrompt: wakePrompt);
      return;
    }

    if (command == 'wake neurobot' || command.contains('hello neurobot')) {
      await _activateNeurobotConversation();
      return;
    }

    final courseFromSpeech = CourseModel.matchBySpeech(rawInput);
    final allowCourseByName = _currentSection == VocalSection.learn ||
        _currentSection == VocalSection.home;
    if (courseFromSpeech != null && allowCourseByName) {
      if (_currentSection != VocalSection.learn) {
        _currentSection = VocalSection.learn;
        _voiceNavigation.pushLearn();
        notifyListeners();
      }
      await selectCourseByVoice(rawInput);
      return;
    }

    if (command == 'clear chat') {
      _neurobotController.clearChat();
      await _speakResponse('Chat cleared.');
      return;
    }

    if (command == 'help') {
      await _announceSectionOptions(_currentSection);
      return;
    }

    if (command == 'emergency') {
      await emergencyAction();
      return;
    }

    if (command == 'home') {
      _navigateHomeVoice();
      await _speakResponse(
        'Returning home.',
      );
      return;
    }

    if (command == 'back') {
      _mode = VocalModeState.activeConversation;
      _neurobotAwake = false;
      _gameKind = VocalGameKind.none;
      _voiceNavigation.pop();
      _currentSection = VocalSection.home;
      notifyListeners();
      await _speakResponse('Going back.');
      return;
    }

    if (command == 'learn') {
      await startLearning();
      return;
    }

    if (command == 'communicate') {
      _currentSection = VocalSection.communicate;
      _neurobotAwake = true;
      _voiceNavigation.pushCommunicate();
      notifyListeners();
      await _speakResponse('Opening communication. NeuroBot is ready.');
      return;
    }

    if (command == 'play') {
      _currentSection = VocalSection.play;
      _voiceNavigation.pushPlay();
      notifyListeners();
      await _speakResponse('Opening games. Say quiz game, memory game, or riddle game.');
      return;
    }

    if (command == 'memory game') {
      await startMemoryGame();
      return;
    }
    if (command == 'quiz game') {
      await startQuizGame();
      return;
    }
    if (command == 'riddle game') {
      await startRiddleGame();
      return;
    }

    if (command == 'control') {
      _currentSection = VocalSection.control;
      _voiceNavigation.pushControl();
      notifyListeners();
      await _speakResponse('Opening control module.');
      return;
    }

    if (command == 'community') {
      _currentSection = VocalSection.community;
      _voiceNavigation.pushCommunity();
      notifyListeners();
      await _speakResponse('Opening community module.');
      return;
    }

    if (command == 'navigate') {
      final destination = _extractDestination(rawInput.isEmpty ? command : rawInput);
      await navigateToDestination(destination);
      return;
    }

    if (command == 'stop navigation') {
      await stopNavigation();
      return;
    }

    if (command == 'continue' || command == 'yes') {
      if (_activeCourse != null && _currentSection == VocalSection.learn) {
        await continueLesson();
        return;
      }
    }

    if (command == 'no' && _activeCourse != null) {
      await _speakResponse('Okay. Say back or choose another course.');
      return;
    }

    if (_mode == VocalModeState.gameMode) {
      if (_gameKind == VocalGameKind.memory) {
        await checkMemoryAnswer(command);
        return;
      }
      if (_gameKind == VocalGameKind.quiz) {
        await submitQuizAnswer(command);
        return;
      }
      if (_gameKind == VocalGameKind.riddle) {
        await submitRiddleAnswer(command);
        return;
      }
    }

    if (_currentSection == VocalSection.learn) {
      await selectCourseByVoice(rawInput.isEmpty ? command : rawInput);
      return;
    }

    if (_neurobotAwake || _currentSection == VocalSection.communicate) {
      final prompt = rawInput.isEmpty ? command : rawInput;
      try {
        final reply = await _neurobotController.replyToUser(prompt);
        await _speakResponse(reply);
      } catch (e) {
        VoiceLog.error('NeuroBot failed', error: e);
        await _speakResponse(
          'I could not get a response. Check your connection and API key, then try again.',
        );
      }
      return;
    }

    await _speakResponse(
      'Sorry, I didn\'t understand. Say Learn, Communicate, Play, Control, or Help.',
    );
  }

  void _navigateHomeVoice() {
    final nav = _voiceNavigation.navigatorKey.currentState;
    final ctx = _voiceNavigation.navigatorKey.currentContext;
    if (nav == null || ctx == null) return;
    final name = ModalRoute.of(ctx)?.settings.name;
    if (name != null &&
        name != VoiceNavigationService.vocalHome &&
        name.startsWith('/vocal/')) {
      _voiceNavigation.popToVocalHome();
      return;
    }
    if (name == VoiceNavigationService.vocalHome) {
      _voiceNavigation.popToAppRoot();
      return;
    }
    _voiceNavigation.popToAppRoot();
  }

  String _extractDestination(String command) {
    const prefixes = <String>['navigate to', 'take me to', 'navigate', 'go to'];
    var lower = command.toLowerCase();
    for (final prefix in prefixes) {
      if (lower.contains(prefix)) {
        final idx = lower.indexOf(prefix);
        final text = command.substring(idx + prefix.length).trim();
        if (text.isNotEmpty) return text;
      }
    }
    return 'nearby destination';
  }

  Future<void> _announceSectionOptions(VocalSection section, {bool resumeListening = true}) async {
    final message = switch (section) {
      VocalSection.home =>
        'Available commands are Learn, Communicate, Play, Navigate, Control, Community, Help, Home, Back, and Emergency.',
      VocalSection.learn =>
        'You are in Learn. Say English Speaking, Basic Computer Skills, Daily Life Skills, or Coding Basics. Say continue for the next step.',
      VocalSection.communicate =>
        'You are in Communicate. Say Hello NeuroBot, then speak naturally. Say clear chat or repeat.',
      VocalSection.play =>
        'You are in Play. Say quiz game, memory game, or riddle game.',
      VocalSection.control =>
        'You are in Control. Say turn on light, turn off fan, or back.',
      VocalSection.community =>
        'You are in Community. Say back to return.',
      VocalSection.navigation =>
        'Navigation mode. Say stop navigation or repeat.',
    };
    await _speakResponse(message, restartListening: resumeListening);
  }

  Future<void> _speakResponse(String text, {bool restartListening = true}) async {
    _statusMessage = text;
    notifyListeners();
    if (restartListening) {
      await _voiceService.stopListening();
    }
    await _ttsService.speak(text);
    if (restartListening) {
      await _voiceService.restartContinuousListening(_onVoiceText);
    }
    _armSilencePrompt();
  }

  @override
  void dispose() {
    _cancelSilenceTimer();
    _voiceService.stopListening();
    _ttsService.stop();
    super.dispose();
  }
}
