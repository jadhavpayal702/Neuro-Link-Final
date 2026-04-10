import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/community_models.dart';
import '../services/community_service.dart';

class RoomChatController extends ChangeNotifier {
  final CommunityService _service;
  final String roomId;
  final String userId;

  RoomChatController({
    required CommunityService service,
    required this.roomId,
    required this.userId,
  }) : _service = service;

  List<RoomMessageModel> _messages = [];
  List<RoomMessageModel> get messages => _messages;

  int _activeCount = 0;
  int get activeCount => _activeCount;

  Timer? _statusTimer;
  StreamSubscription? _msgSub;
  StreamSubscription? _activeSub;

  void initialize() {
    // Stream messages
    _msgSub = _service.streamMessages(roomId).listen((data) {
      _messages = data;
      notifyListeners();
    });

    // Stream active count
    _activeSub = _service.streamActiveMembersCount(roomId).listen((count) {
      _activeCount = count;
      notifyListeners();
    });

    // Update own active status periodically
    _updateStatus();
    _statusTimer = Timer.periodic(const Duration(minutes: 2), (_) => _updateStatus());
  }

  void _updateStatus() {
    _service.updateActiveStatus(roomId, userId);
  }

  Future<void> sendMessage(RoomMessageModel message) async {
    await _service.sendMessage(roomId, message);
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _msgSub?.cancel();
    _activeSub?.cancel();
    super.dispose();
  }
}
