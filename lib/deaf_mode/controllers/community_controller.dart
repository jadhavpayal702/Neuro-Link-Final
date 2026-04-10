import 'package:flutter/foundation.dart';
import '../models/community_models.dart';
import '../services/community_service.dart';

class CommunityController extends ChangeNotifier {
  final CommunityService _service;
  
  CommunityController(this._service);

  List<RoomModel> _rooms = [];
  List<RoomModel> get rooms => _rooms;

  List<StoryModel> _stories = [];
  List<StoryModel> get stories => _stories;

  bool _loading = true;
  bool get loading => _loading;

  void initialize() {
    _service.streamRooms().listen((data) {
      _rooms = data;
      _loading = false;
      notifyListeners();
    });

    _service.streamStories().listen((data) {
      _stories = data;
      notifyListeners();
    });
  }

  Future<void> createRoom(RoomModel room) async {
    await _service.createRoom(room);
  }

  Future<void> joinRoom(String roomId, String userId) async {
    await _service.joinRoom(roomId, userId);
  }

  Future<void> createStory(StoryModel story) async {
    await _service.createStory(story);
  }
}
