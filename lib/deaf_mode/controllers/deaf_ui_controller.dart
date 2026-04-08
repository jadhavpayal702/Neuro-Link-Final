import 'package:flutter/foundation.dart';

import '../models/deaf_ui_models.dart';
import '../services/deaf_ui_data_service.dart';

class DeafUiController extends ChangeNotifier {
  DeafUiController(this._service);

  final DeafUiDataService _service;

  bool loading = true;
  List<CourseItem> courses = [];
  List<VideoItem> videos = [];
  List<ChatItem> chat = [];
  List<GameItem> games = [];
  List<RoomItem> rooms = [];
  List<DeviceItem> devices = [];
  UserProfile profile = UserProfile(name: '', email: '', phone: '');

  Future<void> initialize() async {
    loading = true;
    notifyListeners();
    courses = await _service.loadCourses();
    videos = await _service.loadVideos();
    chat = await _service.loadChat();
    games = await _service.loadGames();
    rooms = await _service.loadRooms();
    devices = await _service.loadDevices();
    profile = await _service.loadProfile();
    loading = false;
    notifyListeners();
  }

  Future<void> sendChat(String message) async {
    final now = DateTime.now();
    final h = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final m = now.minute.toString().padLeft(2, '0');
    final suffix = now.hour >= 12 ? 'PM' : 'AM';
    chat.add(
      ChatItem(
        sender: profile.name,
        message: message,
        time: '$h:$m $suffix',
        isUser: true,
      ),
    );
    await _service.saveChat(chat);
    notifyListeners();
  }

  Future<void> toggleDevice(int index, bool value) async {
    devices[index].on = value;
    await _service.saveDevices(devices);
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile updated) async {
    profile = updated;
    await _service.saveProfile(updated);
    notifyListeners();
  }
}
