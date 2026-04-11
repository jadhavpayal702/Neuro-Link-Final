import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:neuro_link/eye-mode/eye_tracking/gaze_blink_pipeline.dart';
import 'package:neuro_link/eye-mode/services/facemesh.dart';
import 'package:neuro_link/eye-mode/models/video.dart';
import 'package:neuro_link/eye-mode/screens/learn_section.dart';
import 'package:neuro_link/eye-mode/screens/learn_video_page.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:neuro_link/eye-mode/models/learn_data.dart';
import 'package:neuro_link/eye-mode/screens/games_menu.dart';
import 'package:neuro_link/eye-mode/screens/game_word_builder.dart';
import 'package:neuro_link/eye-mode/screens/game_picture_match.dart';
import 'package:neuro_link/eye-mode/screens/game_spell_it.dart';
import 'package:neuro_link/eye-mode/screens/game_find_word.dart';
import 'package:neuro_link/eye-mode/models/game_models.dart';
import 'package:neuro_link/eye-mode/screens/smart_control_page.dart';

enum _EyePage {
  instructions,
  calibration,
  dashboard,
  communicate,
  learn,
  learnVideos,
  games,
  gamesMenu,
  gameWordBuilder,
  gamePictureMatch,
  gameSpellIt,
  gameFindWord,
  smart
}

class EyeUnlockScreen extends StatefulWidget {
  const EyeUnlockScreen({super.key});

  @override
  State<EyeUnlockScreen> createState() => _EyeUnlockScreenState();
}

class _EyeUnlockScreenState extends State<EyeUnlockScreen>
    with SingleTickerProviderStateMixin {
  _EyePage _page = _EyePage.instructions;
  late final AnimationController _dotController;
  String _typedText = '';
  bool _lightOn = false;
  bool _fanOn = false;
  bool _sosArmed = false;
  int _targetHits = 0;
  int _reactionHits = 0;
  bool _reactionReady = false;
  Offset _targetPos = const Offset(0.35, 0.55);

  String _selectedCategory = '';
  List<Video> _selectedVideos = [];

  late final GazePipeline _gazePipeline;
  final ValueNotifier<int?> _selectTrigger = ValueNotifier<int?>(null);
  bool _faceDetected = false;
  String _blinkStatus = 'OPEN';
  double _lastGazeConfidence = 0;
  Offset _cursorNorm = const Offset(0.5, 0.5);
  int _focusIndex = 0;
  int _focusCount = 1;
  final Map<int, GlobalKey> _focusKeys = <int, GlobalKey>{};
  late final FlutterTts _tts;
  bool _isSpeaking = false;
  int _lastFocusIndex = -1;
  int _debugFrameCount = 0;

  // Calibration baseline capture.
  final Map<String, Offset> _calibration = {};
  String _calibrationPrompt = 'Look LEFT and tap Start Calibration';
  static const List<String> _quickPhrases = [
    'I need water',
    'I am hungry',
    'Take me to washroom',
    'I need help',
    'Call doctor',
    'I am feeling pain',
    'Thank you',
    'Yes',
    'No',
  ];

  static const _bg = Color(0xFF0F0F0F); // Deep Charcoal
  static const _surface = Color(0xFF1A1A1A);
  static const _accent = Color(0xFFFF6A00); // Futuristic Orange
  static const _accentBlue = Color(0xFF36C2FF);
  static const _success = Color(0xFF22C55E);

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    _gazePipeline = GazePipeline();
    _tts = FlutterTts();
    _tts.setSpeechRate(0.45);
    _tts.setVolume(1.0);
    _tts.awaitSpeakCompletion(true);
    _tts.setStartHandler(() {
      if (!mounted) return;
      setState(() => _isSpeaking = true);
    });
    _tts.setCompletionHandler(() {
      if (!mounted) return;
      setState(() => _isSpeaking = false);
    });
    _tts.setErrorHandler((_) {
      if (!mounted) return;
      setState(() => _isSpeaking = false);
    });
    Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || _page != _EyePage.games) return;
      setState(() => _reactionReady = !_reactionReady);
    });
    unawaited(_initCamera());
  }

  @override
  void dispose() {
    stopFaceMeshNative();
    _tts.stop();
    _dotController.dispose();
    super.dispose();
  }

  void _goTo(_EyePage page) {
    if (page != _page) {
      _focusKeys.clear();
    }
    setState(() => _page = page);
  }

  Future<void> _initCamera() async {
    if (!kIsWeb) {
      final permission = await Permission.camera.request();
      if (!permission.isGranted) return;
    }

    startFaceMeshNative((String data) {
      if (!mounted) return;
      try {
        final json = jsonDecode(data);
        final double x = json['x']?.toDouble() ?? 0.5;
        final double y = json['y']?.toDouble() ?? 0.5;
        final String blinkStr = json['blink'] ?? 'none';

        _debugFrameCount++;
        if (_debugFrameCount % 30 == 0) {
          debugPrint('[EyeTrack] frame=$_debugFrameCount  gaze=($x, $y)  blink=$blinkStr');
        }

        final gazeNorm = Offset(x, y);
        final mapped = GazePipeline.mapGazeToCursor(
          gazeNorm: gazeNorm,
          calibration: _calibration,
        );

        _gazePipeline.update(
          measuredNorm: gazeNorm,
          confidence: 1.0,
          mappedTargetNorm: mapped,
        );

        BlinkGesture gesture = BlinkGesture.none;
        if (blinkStr == 'single') gesture = BlinkGesture.singleClick;
        if (blinkStr == 'double') gesture = BlinkGesture.doubleBack;
        if (blinkStr == 'triple') gesture = BlinkGesture.tripleEmergency;

        setState(() {
          _faceDetected = true;
          _lastGazeConfidence = 1.0;
          _cursorNorm = _gazePipeline.cursorNorm;
          _blinkStatus = blinkStr.toUpperCase();
        });

        if (gesture != BlinkGesture.none) {
          _handleBlinkGesture(gesture);
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _syncFocusFromCursor();
        });
      } catch (e) {
        debugPrint('FaceMesh JSON Parse Error: $e');
      }
    });
  }

  void _handleBlinkGesture(BlinkGesture gesture) {
    switch (gesture) {
      case BlinkGesture.none:
        return;
      case BlinkGesture.singleClick:
        _activateFocused();
        return;
      case BlinkGesture.doubleBack:
        _goPrevModule();
        return;
      case BlinkGesture.tripleEmergency:
        unawaited(_triggerEmergency());
        return;
    }
  }

  Future<void> _triggerEmergency() async {
    if (!mounted) return;
    await _tts.stop();
    await _tts.speak('Emergency detected. Help is being called.');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Emergency alert — help flow triggered'),
        duration: Duration(seconds: 4),
        backgroundColor: Color(0xFFB71C1C),
      ),
    );
  }

  void _syncFocusFromCursor() {
    if (_focusKeys.isEmpty) return;
    final size = MediaQuery.of(context).size;
    final cursorPx = Offset(
      _cursorNorm.dx * size.width,
      _cursorNorm.dy * size.height,
    );
    int? bestIdx;
    double best = double.infinity;
    for (final entry in _focusKeys.entries) {
      final ctx = entry.value.currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject();
      if (box is! RenderBox || !box.hasSize) continue;
      final topLeft = box.localToGlobal(Offset.zero);
      final rect = topLeft & box.size;
      if (rect.contains(cursorPx)) {
        bestIdx = entry.key;
        break;
      }
      final center = rect.center;
      final d2 =
          (center.dx - cursorPx.dx) * (center.dx - cursorPx.dx) +
          (center.dy - cursorPx.dy) * (center.dy - cursorPx.dy);
      if (d2 < best) {
        best = d2;
        bestIdx = entry.key;
      }
    }
    if (bestIdx != null && bestIdx != _focusIndex) {
      setState(() => _focusIndex = bestIdx!);
    }
  }

  void _activateFocused() {
    switch (_page) {
      case _EyePage.dashboard:
        if (_focusIndex == 0) _goTo(_EyePage.communicate);
        if (_focusIndex == 1) _goTo(_EyePage.learn);
        if (_focusIndex == 2) _goTo(_EyePage.games);
        if (_focusIndex == 3) _goTo(_EyePage.smart);
      case _EyePage.communicate:
        _activateCommunicate();
      case _EyePage.learn:
        if (_focusIndex >= 0 && _focusIndex <= 5) {
          final categories = learnContent.keys.toList();
          final cat = categories[_focusIndex];
          final videosMapping = learnContent[cat]!;
          final videos = videosMapping.map((m) => Video.fromMap(m)).toList();
          setState(() {
            _selectedCategory = cat;
            _selectedVideos = videos;
            _goTo(_EyePage.learnVideos);
          });
        }
        if (_focusIndex == _focusCount - 2) _goPrevModule();
        if (_focusIndex == _focusCount - 1) _goNextModule();
      case _EyePage.learnVideos:
        if (_focusIndex >= 0 && _focusIndex < _selectedVideos.length) {
          _launchUrl(_selectedVideos[_focusIndex].url);
        }
        if (_focusIndex == _focusCount - 2) _goPrevModule();
        if (_focusIndex == _focusCount - 1) _goNextModule();
      case _EyePage.games:
        _goTo(_EyePage.gamesMenu);
      case _EyePage.gamesMenu:
        if (_focusIndex == 0) _goTo(_EyePage.gameWordBuilder);
        if (_focusIndex == 1) _goTo(_EyePage.gamePictureMatch);
        if (_focusIndex == 2) _goTo(_EyePage.gameSpellIt);
        if (_focusIndex == 3) _goTo(_EyePage.gameFindWord);
      case _EyePage.gameWordBuilder:
      case _EyePage.gamePictureMatch:
      case _EyePage.gameSpellIt:
      case _EyePage.gameFindWord:
        _selectTrigger.value = _focusIndex;
        // Reset after trigger so subsequent clicks on same item work
        Future.delayed(const Duration(milliseconds: 50), () => _selectTrigger.value = null);
        break;
      case _EyePage.smart:
        _selectTrigger.value = _focusIndex;
        // Reset after trigger
        Future.delayed(const Duration(milliseconds: 50), () => _selectTrigger.value = null);
        setState(() {});
      case _EyePage.calibration:
        _captureCalibrationStep();
      case _EyePage.instructions:
        _goTo(_EyePage.dashboard);
        _focusIndex = 0;
    }
  }

  void _showHint(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        duration: const Duration(milliseconds: 900),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _showHint('Could not launch video');
    }
  }

  void _activateCommunicate() {
    const keyRows = ['QWERTYUIOP', 'ASDFGHJKL', 'ZXCVBNM'];
    final keys = <String>[];
    for (final row in keyRows) {
      keys.addAll(row.split(''));
    }
    keys.addAll(['Space', 'Back', 'Enter', 'Speak']);
    keys.addAll(_quickPhrases);
    keys.addAll(['Previous', 'Next']);
    if (_focusIndex >= keys.length) return;
    final key = keys[_focusIndex];
    setState(() {
      if (key == 'Space') _typedText += ' ';
      if (key == 'Back') {
        _typedText = _typedText.isEmpty
            ? ''
            : _typedText.substring(0, _typedText.length - 1);
      }
      if (key == 'Enter') {
        unawaited(_speakText(_typedText, clearAfterSpeak: true));
      }
      if (key == 'Speak') {
        unawaited(_speakText(_typedText, clearAfterSpeak: true));
      }
      if (key == 'Previous') _goPrevModule();
      if (key == 'Next') _goNextModule();
      if (_quickPhrases.contains(key)) {
        _typedText = key;
        unawaited(_speakText(key, clearAfterSpeak: false));
      }
      if (key.length == 1) _typedText += key;
    });
  }

  Future<void> _speakText(String text, {bool clearAfterSpeak = false}) async {
    final content = text.trim();
    if (content.isEmpty) return;
    await _tts.stop();
    await _tts.speak(content);
    if (clearAfterSpeak && mounted) {
      setState(() => _typedText = '');
    }
  }

  void _captureCalibrationStep() {
    if (!_faceDetected) return;
    if (!_calibration.containsKey('LEFT')) {
      _calibration['LEFT'] = _gazePipeline.raw;
      _calibrationPrompt = 'Look RIGHT and blink/tap Start';
    } else if (!_calibration.containsKey('RIGHT')) {
      _calibration['RIGHT'] = _gazePipeline.raw;
      _calibrationPrompt = 'Look UP and blink/tap Start';
    } else if (!_calibration.containsKey('UP')) {
      _calibration['UP'] = _gazePipeline.raw;
      _calibrationPrompt = 'Look DOWN and blink/tap Start';
    } else if (!_calibration.containsKey('DOWN')) {
      _calibration['DOWN'] = _gazePipeline.raw;
      _calibrationPrompt = 'Calibration complete. Start EyeUnlock';
    } else {
      _goTo(_EyePage.dashboard);
      _focusIndex = 0;
    }
    setState(() {});
  }

  void _goNextModule() {
    switch (_page) {
      case _EyePage.communicate:
        _goTo(_EyePage.learn);
        return;
      case _EyePage.learn:
        _goTo(_EyePage.learnVideos);
        return;
      case _EyePage.learnVideos:
        _goTo(_EyePage.games);
        return;
      case _EyePage.games:
      case _EyePage.gamesMenu:
      case _EyePage.gameWordBuilder:
      case _EyePage.gamePictureMatch:
      case _EyePage.gameSpellIt:
      case _EyePage.gameFindWord:
        _goTo(_EyePage.smart);
        return;
      case _EyePage.smart:
        _goTo(_EyePage.communicate);
        return;
      case _EyePage.instructions:
      case _EyePage.calibration:
      case _EyePage.dashboard:
        _goTo(_EyePage.dashboard);
        setState(() {
          _focusCount = 5;
          _focusIndex = 0;
        });
        return;
    }
  }

  void _goPrevModule() {
    switch (_page) {
      case _EyePage.communicate:
        _goTo(_EyePage.dashboard);
        return;
      case _EyePage.learn:
        _goTo(_EyePage.dashboard);
        return;
      case _EyePage.learnVideos:
        _goTo(_EyePage.learn);
        return;
      case _EyePage.games:
      case _EyePage.gamesMenu:
      case _EyePage.gameWordBuilder:
      case _EyePage.gamePictureMatch:
      case _EyePage.gameSpellIt:
      case _EyePage.gameFindWord:
        _goTo(_EyePage.dashboard);
        return;
      case _EyePage.smart:
        _goTo(_EyePage.dashboard);
        return;
      case _EyePage.instructions:
      case _EyePage.calibration:
      case _EyePage.dashboard:
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: switch (_page) {
                _EyePage.instructions => _buildCenteredWrapper(_buildInstructions()),
                _EyePage.calibration => _buildCenteredWrapper(_buildCalibration()),
                _EyePage.dashboard => _buildCenteredWrapper(_buildDashboard()),
                _EyePage.communicate => _buildCenteredWrapper(_buildCommunicate()),
                _EyePage.learn => _buildCenteredWrapper(_buildLearn()),
                _EyePage.learnVideos => _buildCenteredWrapper(_buildLearnVideos()),
                _EyePage.games => _buildCenteredWrapper(_buildGamesMenu()),
                _EyePage.gamesMenu => _buildCenteredWrapper(_buildGamesMenu()),
                _EyePage.gameWordBuilder => _buildWordBuilder(),
                _EyePage.gamePictureMatch => _buildPictureMatch(),
                _EyePage.gameSpellIt => _buildSpellIt(),
                _EyePage.gameFindWord => _buildFindWord(),
                _EyePage.smart => _buildCenteredWrapper(
                  SmartControlPage(
                    focusableBuilder: _focusable,
                    focusIndex: _focusIndex,
                    selectTrigger: _selectTrigger,
                    lightOn: _lightOn,
                    fanOn: _fanOn,
                    sosArmed: _sosArmed,
                    onToggleLight: () => setState(() => _lightOn = !_lightOn),
                    onToggleFan: () => setState(() => _fanOn = !_fanOn),
                    onTriggerSOS: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('SOS activated')),
                      );
                    },
                    sectionHeader: _sectionHeader('Smart Control'),
                    bottomNav: _bottomNav(),
                  ),
                ),
              },
            ),
          ),
          Positioned(right: 10, top: 44, child: _buildDebugOverlay()),
          Positioned(
            left: _cursorNorm.dx * MediaQuery.of(context).size.width - 20,
            top: _cursorNorm.dy * MediaQuery.of(context).size.height - 20,
            child: IgnorePointer(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Pulse Halo
                        AnimatedBuilder(
                          animation: _dotController,
                          builder: (context, child) {
                            return Container(
                              width: 38 + (sin(_dotController.value * 2 * pi) * 6),
                              height: 38 + (sin(_dotController.value * 2 * pi) * 6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _accent.withOpacity(0.4),
                                  width: 2,
                                ),
                              ),
                            );
                          },
                        ),
                        // Sharp Center
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: _accent.withOpacity(0.6),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebugOverlay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DefaultTextStyle(
        style: const TextStyle(color: Colors.white, fontSize: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('MediaPipe FaceMesh Active'),
            Text('Face: ${_faceDetected ? "YES" : "NO"}'),
            Text('Frames: $_debugFrameCount'),
            Text('Raw gaze: ${_gazePipeline.raw.dx.toStringAsFixed(3)}, ${_gazePipeline.raw.dy.toStringAsFixed(3)}'),
            Text('Gaze conf: ${_lastGazeConfidence.toStringAsFixed(2)}'),
            Text('Blink: $_blinkStatus'),
            Text(
              'Cursor: ${_cursorNorm.dx.toStringAsFixed(2)}, ${_cursorNorm.dy.toStringAsFixed(2)}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    _focusCount = 1;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'How to Use Eye Unlock',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32, // Reduced from 48
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Professional hands-free interface powered by NeuroLink',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 15, // Reduced from 18
          ),
        ),
        const SizedBox(height: 50),
        Wrap(
          spacing: 16, // Reduced from 24
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: [
            _modernInstructionStep(Icons.visibility_rounded, 'Precision Gaze', 'Move your eyes to control the cursor position.'),
            _modernInstructionStep(Icons.ads_click_rounded, 'Single Blink', 'A quick blink triggers the selection on focused elements.'),
            _modernInstructionStep(Icons.sensors_rounded, 'Environment', 'Ensure your face is well-lit for optimal results.'),
          ],
        ),
        const SizedBox(height: 40), // Reduced from 60
        SizedBox(
          width: 260, // Reduced from 320
          child: _focusable(
            index: 0,
            child: _largeButton(
              label: 'Get Started',
              color: _accent,
              textColor: Colors.black,
              onTap: () => _goTo(_EyePage.dashboard),
            ),
          ),
        ),
      ],
    );
  }

  Widget _modernInstructionStep(IconData icon, String title, String desc) {
    return Container(
      width: 240, // Reduced from 280
      padding: const EdgeInsets.all(20), // Reduced from 24
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: _accent, size: 28), // Reduced from 32
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), // Reduced from 20
          const SizedBox(height: 8),
          Text(desc, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)), // Reduced from 14
        ],
      ),
    );
  }

  Widget _instructionStep(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: _accent.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: _accent, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 18, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalibration() {
    const points = <Alignment>[
      Alignment(0, -0.8),
      Alignment(-0.8, 0),
      Alignment(0.8, 0),
      Alignment(0, 0.8),
      Alignment.center,
    ];
    return Column(
      children: [
        const SizedBox(height: 6),
        const Text(
          'Eye Calibration',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Follow the dots with your eyes to calibrate',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFFB8D5FF), fontSize: 18),
        ),
        const SizedBox(height: 8),
        Text(
          _calibrationPrompt,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 15),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.06), width: 1.5),
            ),
            child: AnimatedBuilder(
              animation: _dotController,
              builder: (context, _) {
                final idx =
                    (_dotController.value * points.length).floor() %
                    points.length;
                return Stack(
                  children: [
                    for (final point in points)
                      Align(
                        alignment: point,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white30),
                          ),
                        ),
                      ),
                    Align(
                      alignment: points[idx],
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: _accent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: _accent, blurRadius: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _focusable(
                index: 0,
                child: _largeButton(
                  label: 'Skip',
                  color: const Color(0xFF2B3F61),
                  onTap: () => _goTo(_EyePage.dashboard),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _focusable(
                index: 1,
                child: _largeButton(
                  label: 'Start Calibration',
                  color: _accent,
                  textColor: Colors.black,
                  onTap: _captureCalibrationStep,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDashboard() {
    _focusCount = 5;
    return Column(
      children: [
        _sectionHeader('Dashboard'),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.8, // Shorter cards to fit more content
            children: [
              _focusable(
                index: 0,
                child: _dashboardCard(
                  'Communicate',
                  Icons.chat_bubble_outline_rounded,
                  'Type with your eyes instantly.',
                  _accentBlue,
                  () => _goTo(_EyePage.communicate),
                ),
              ),
              _focusable(
                index: 1,
                child: _dashboardCard(
                  'Learn',
                  Icons.auto_stories_rounded,
                  'Educational resources and guides.',
                  _success,
                  () => _goTo(_EyePage.learn),
                ),
              ),
              _focusable(
                index: 2,
                child: _dashboardCard(
                  'Games',
                  Icons.sports_esports_rounded,
                  'Engaging eye-training games.',
                  const Color(0xFFF97316),
                  () => _goTo(_EyePage.gamesMenu),
                ),
              ),
              _focusable(
                index: 3,
                child: _dashboardCard(
                  'Smart Control',
                  Icons.sensors_rounded,
                  'Control your environment easily.',
                  const Color(0xFF8B5CF6),
                  () => _goTo(_EyePage.smart),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _focusable(
          index: 4,
          child: _largeButton(
            label: 'Recalibrate Tracker',
            color: Colors.white.withOpacity(0.08),
            textColor: Colors.white,
            onTap: () => _goTo(_EyePage.calibration),
          ),
        ),
      ],
    );
  }

  Widget _buildCommunicate() {
    _focusCount = 41;
    const rows = ['QWERTYUIOP', 'ASDFGHJKL', 'ZXCVBNM'];
    const chars = 'QWERTYUIOPASDFGHJKLZXCVBNM';
    int keyIndex = 0;
    return Column(
      children: [
        _sectionHeader('Communicate'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 96,
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Text(
                  _typedText.isEmpty
                      ? 'Gaze to start typing...'
                      : _typedText,
                  style: TextStyle(
                    color: Colors.white.withOpacity(_typedText.isEmpty ? 0.3 : 0.9),
                    fontSize: 20, // Reduced from 24
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 80, // Reduced from 96
              width: 100, // Reduced from 106
              child: _focusable(
                index: 29,
                child: _largeButton(
                  label: _isSpeaking ? 'Speaking...' : 'Speak',
                  color: _isSpeaking ? const Color(0xFF26A69A) : _accent,
                  textColor: Colors.black,
                  onTap: () =>
                      unawaited(_speakText(_typedText, clearAfterSpeak: true)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              const rowGap = 8.0;
              final keyRowHeight = (constraints.maxHeight - (rowGap * 3)) / 4;
              return Column(
                children: [
                  for (final row in rows) ...[
                    SizedBox(
                      height: keyRowHeight,
                      child: Row(
                        children: [
                          for (var i = 0; i < row.length; i++) ...[
                            Expanded(
                              child: _focusable(
                                index: keyIndex++,
                                child: _keyButton(
                                  row[i],
                                  onTap: () =>
                                      setState(() => _typedText += row[i]),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                        ]..removeLast(),
                      ),
                    ),
                    const SizedBox(height: rowGap),
                  ],
                  SizedBox(
                    height: keyRowHeight,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _focusable(
                            index: chars.length,
                            child: _keyButton(
                              'Space',
                              onTap: () => setState(() => _typedText += ' '),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _focusable(
                            index: chars.length + 1,
                            child: _keyButton(
                              'Back',
                              onTap: () => setState(
                                () => _typedText = _typedText.isEmpty
                                    ? ''
                                    : _typedText.substring(
                                        0,
                                        _typedText.length - 1,
                                      ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _focusable(
                            index: chars.length + 2,
                            child: _keyButton(
                              'Enter',
                              onTap: () => unawaited(
                                _speakText(_typedText, clearAfterSpeak: true),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120, // Reduced from 140
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: _accent, size: 16),
                    const SizedBox(width: 8),
                    const Text(
                      'QUICK PHRASES',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _quickPhrases.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      return SizedBox(
                        width: 160, // Reduced from 190
                        child: _focusable(
                          index: 30 + i,
                          child: _largeButton(
                            label: _quickPhrases[i],
                            color: Colors.white.withOpacity(0.08),
                            onTap: () {
                              setState(() => _typedText = _quickPhrases[i]);
                              unawaited(
                                _speakText(
                                  _quickPhrases[i],
                                  clearAfterSpeak: false,
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        _bottomNav(),
      ],
    );
  }

  Widget _buildLearn() {
    _focusCount = 8;
    return Column(
      children: [
        _sectionHeader('Learn'),
        const SizedBox(height: 10),
        Expanded(
          child: LearnSection(
            focusableBuilder: _focusable,
            focusStartIndex: 0,
            focusIndex: _focusIndex,
            onCategorySelected: (cat, videos) {
              setState(() {
                _selectedCategory = cat;
                _selectedVideos = videos;
                _goTo(_EyePage.learnVideos);
              });
            },
          ),
        ),
        const SizedBox(height: 12),
        _bottomNav(),
      ],
    );
  }

  Widget _buildLearnVideos() {
    _focusCount = 7;
    return Column(
      children: [
        _sectionHeader(_selectedCategory),
        const SizedBox(height: 10),
        Expanded(
          child: LearnVideoPage(
            title: _selectedCategory,
            videos: _selectedVideos,
            focusableBuilder: _focusable,
            focusStartIndex: 0,
            focusIndex: _focusIndex,
            onBack: () => _goTo(_EyePage.learn),
          ),
        ),
        const SizedBox(height: 12),
        _bottomNav(),
      ],
    );
  }

  Widget _buildGamesMenu() {
    _focusCount = 4;
    return GamesMenu(
      focusableBuilder: _focusable,
      focusIndex: _focusIndex,
      onGameSelected: (idx) {
        if (idx == 0) _goTo(_EyePage.gameWordBuilder);
        if (idx == 1) _goTo(_EyePage.gamePictureMatch);
        if (idx == 2) _goTo(_EyePage.gameSpellIt);
        if (idx == 3) _goTo(_EyePage.gameFindWord);
      },
    );
  }

  Widget _buildWordBuilder() {
    _focusCount = 10;
    return GameWordBuilder(
      focusableBuilder: _focusable,
      focusIndex: _focusIndex,
      selectTrigger: _selectTrigger,
      onWin: () {
        _showHint('Great Job! Word Completed.');
        _goTo(_EyePage.gamesMenu);
      },
    );
  }

  Widget _buildPictureMatch() {
    _focusCount = 12;
    return GamePictureMatch(
      focusableBuilder: _focusable,
      focusIndex: _focusIndex,
      selectTrigger: _selectTrigger,
      onWin: () {
        _showHint('Memory Mastered!');
        _goTo(_EyePage.gamesMenu);
      },
    );
  }

  Widget _buildSpellIt() {
    _focusCount = 26;
    return GameSpellIt(
      focusableBuilder: _focusable,
      focusIndex: _focusIndex,
      selectTrigger: _selectTrigger,
      onWin: () {
        _showHint('Spelling Perfected!');
        _goTo(_EyePage.gamesMenu);
      },
    );
  }

  Widget _buildFindWord() {
    _focusCount = 16;
    return GameFindWord(
      focusableBuilder: _focusable,
      focusIndex: _focusIndex,
      selectTrigger: _selectTrigger,
      onWin: () {
        _showHint('Word Found!');
        _goTo(_EyePage.gamesMenu);
      },
    );
  }


  Widget _sectionHeader(String title) {
    return Container(
      height: 64, // Reduced from 80
      padding: const EdgeInsets.symmetric(horizontal: 20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Icon(Icons.bolt_rounded, color: _accent, size: 24), // Reduced from 28
          const SizedBox(width: 10),
          Text(
            'NEUROLINK',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12, // Reduced from 14
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 11, // Reduced from 12
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(width: 12),
          if (_page != _EyePage.dashboard)
            _focusable(
              index: _focusCount - 1,
              child: InkWell(
                onTap: () => _goTo(_EyePage.dashboard),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.home_rounded, color: _accent, size: 18), // Reduced from 20
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _dashboardCard(String title, IconData icon, String desc, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20), // Slightly sharper corners for compact
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20), // Reduced from 32
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10), // Reduced from 12
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 28, color: color), // Reduced from 36
                ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800), // Reduced from 24
                ),
                const SizedBox(height: 6), // Reduced from 8
                Text(
                  desc,
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, height: 1.3), // Reduced from 14
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _gamePanel({
    required String title,
    required Color color,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A3D61)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }


  Widget _keyButton(String label, {VoidCallback? onTap}) {
    return SizedBox(
      height: double.infinity,
      child: ElevatedButton(
        onPressed: onTap ?? () => setState(() => _typedText += label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.03),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.white.withOpacity(0.08), width: 1.2),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _largeButton({
    required String label,
    required Color color,
    Color textColor = Colors.white,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 64,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 0.5),
        ),
        child: Text(label),
      ),
    );
  }

  Widget _bottomNav() {
    final prevIndex = _page == _EyePage.communicate ? 39 : _focusCount - 2;
    final nextIndex = _page == _EyePage.communicate ? 40 : _focusCount - 1;
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Expanded(
            child: _focusable(
              index: prevIndex,
              child: _largeButton(
                label: 'Previous',
                color: const Color(0xFF2B3F61),
                onTap: _goPrevModule,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _focusable(
              index: nextIndex,
              child: _largeButton(
                label: 'Next',
                color: _accent,
                textColor: Colors.black,
                onTap: _goNextModule,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenteredWrapper(Widget child) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 880), // Reduced from 1000
        child: child,
      ),
    );
  }

  Widget _focusable({required int index, required Widget child}) {
    final key = _focusKeys.putIfAbsent(index, () => GlobalKey());
    final focused = _focusIndex == index;
    return AnimatedScale(
      scale: focused ? 1.03 : 1.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      child: AnimatedContainer(
        key: key,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: focused ? _accent : Colors.white.withOpacity(0.08),
            width: focused ? 3.5 : 1.5,
          ),
          boxShadow: focused
              ? [
                  BoxShadow(
                    color: _accent.withOpacity(0.2),
                    blurRadius: 25,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
        padding: const EdgeInsets.all(2),
        child: child,
      ),
    );
  }
}
