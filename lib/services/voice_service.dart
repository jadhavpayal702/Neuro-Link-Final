import 'dart:async';

import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

import 'voice_log.dart';

typedef VoiceTextCallback = void Function(String text, bool isFinal);

/// Single-listener speech service with guarded restarts (no stacked sessions).
class VoiceService {
  VoiceService();

  final SpeechToText _speech = SpeechToText();
  VoiceTextCallback? _onText;
  bool _continuous = true;
  bool _active = true;
  bool _paused = false;
  bool _initialized = false;
  bool _listenCycleInFlight = false;
  Timer? _restartDebounce;
  static const _restartDebounceMs = 320;

  bool get isListening => _speech.isListening;
  bool get isInitialized => _initialized;
  bool get isPaused => _paused;
  Future<bool> get hasPermission => _speech.hasPermission;

  Future<bool> initialize() async {
    _initialized = await _speech.initialize(
      onStatus: _handleStatus,
      onError: _handleError,
    );
    VoiceLog.listener('initialize done=$_initialized', detail: null);
    return _initialized;
  }

  /// Pause: stop engine; no restarts until [resumeListening].
  Future<void> pauseListening() async {
    _paused = true;
    _restartDebounce?.cancel();
    await _stopListenSafe();
    VoiceLog.listener('paused', detail: null);
  }

  Future<void> resumeListening() async {
    _paused = false;
    _active = true;
    _continuous = true;
    await _scheduleListen(reason: 'resume');
  }

  Future<void> startConversationListening(VoiceTextCallback onText) async {
    _onText = onText;
    _continuous = true;
    _active = true;
    _paused = false;
    await _scheduleListen(reason: 'start');
  }

  Future<void> restartContinuousListening(VoiceTextCallback onText) async {
    _onText = onText;
    _continuous = true;
    _active = true;
    await _scheduleListen(reason: 'restart_after_tts');
  }

  Future<void> stopListening() async {
    _active = false;
    _continuous = false;
    _restartDebounce?.cancel();
    await _stopListenSafe();
    VoiceLog.listener('stopListening', detail: null);
  }

  Future<void> _stopListenSafe() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
  }

  Future<void> _scheduleListen({required String reason}) async {
    if (!_initialized || _paused || !_active) return;
    _restartDebounce?.cancel();
    _restartDebounce = Timer(const Duration(milliseconds: _restartDebounceMs), () {
      unawaited(_startListenCycle(reason: reason));
    });
  }

  Future<void> _startListenCycle({required String reason}) async {
    if (!_initialized || _paused || !_active) return;
    if (_listenCycleInFlight) {
      VoiceLog.listener('skip duplicate listen cycle', detail: reason);
      return;
    }
    if (_speech.isListening) {
      VoiceLog.listener('already listening', detail: reason);
      return;
    }
    _listenCycleInFlight = true;
    try {
      VoiceLog.listener('listen start', detail: reason);
      await _speech.listen(
        onResult: _handleResult,
        listenFor: const Duration(minutes: 30),
        pauseFor: const Duration(seconds: 3),
        listenOptions: SpeechListenOptions(
          partialResults: true,
          cancelOnError: false,
          listenMode: ListenMode.dictation,
        ),
      );
    } catch (e, st) {
      VoiceLog.error('listen failed', error: e, stack: st);
      VoiceLog.recovery('Scheduling listen retry after error');
      if (_active && !_paused) {
        await _scheduleListen(reason: 'recover_after_error');
      }
    } finally {
      _listenCycleInFlight = false;
    }
  }

  void _handleResult(SpeechRecognitionResult result) {
    final text = result.recognizedWords.trim();
    if (text.isEmpty) return;
    VoiceLog.speech(
      result.finalResult ? 'FINAL' : 'partial',
      detail: text,
    );
    _onText?.call(text, result.finalResult);
  }

  void _handleStatus(String status) {
    VoiceLog.listener('status=$status', detail: 'continuous=$_continuous active=$_active paused=$_paused');
    final shouldRestart = _active &&
        !_paused &&
        _continuous &&
        (status == 'done' || status == 'notListening');
    if (shouldRestart) {
      unawaited(_scheduleListen(reason: 'status_$status'));
    }
  }

  void _handleError(dynamic error) {
    VoiceLog.error('speech error', error: error);
    VoiceLog.recovery('Restarting listener after speech error');
    if (_active && !_paused) {
      unawaited(_scheduleListen(reason: 'onError'));
    }
  }
}
