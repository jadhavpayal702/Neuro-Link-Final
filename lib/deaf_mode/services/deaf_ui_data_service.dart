import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/deaf_ui_models.dart';

class DeafUiDataService {
  static const _profileKey = 'deaf_profile';
  static const _chatKey = 'deaf_chat';
  static const _deviceKey = 'deaf_devices';

  Future<Map<String, dynamic>> _loadAsset(String path) async {
    final raw = await rootBundle.loadString(path);
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  Future<List<CourseItem>> loadCourses() async {
    final json = await _loadAsset('assets/deaf_mode/learn.json');
    return List<Map<String, dynamic>>.from(
      json['courses'] as List,
    ).map(CourseItem.fromJson).toList();
  }

  Future<List<VideoItem>> loadVideos() async {
    final json = await _loadAsset('assets/deaf_mode/learn.json');
    return List<Map<String, dynamic>>.from(
      json['videos'] as List,
    ).map(VideoItem.fromJson).toList();
  }

  Future<List<ChatItem>> loadChat() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_chatKey);
    if (saved != null && saved.isNotEmpty) {
      return List<Map<String, dynamic>>.from(
        jsonDecode(saved) as List,
      ).map(ChatItem.fromJson).toList();
    }
    final json = await _loadAsset('assets/deaf_mode/communicate.json');
    return List<Map<String, dynamic>>.from(
      json['messages'] as List,
    ).map(ChatItem.fromJson).toList();
  }

  Future<void> saveChat(List<ChatItem> data) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = data
        .map(
          (e) => {
            'sender': e.sender,
            'message': e.message,
            'time': e.time,
            'isUser': e.isUser,
          },
        )
        .toList();
    await prefs.setString(_chatKey, jsonEncode(payload));
  }

  Future<List<GameItem>> loadGames() async {
    final json = await _loadAsset('assets/deaf_mode/play.json');
    return List<Map<String, dynamic>>.from(
      json['games'] as List,
    ).map(GameItem.fromJson).toList();
  }

  Future<List<RoomItem>> loadRooms() async {
    final json = await _loadAsset('assets/deaf_mode/community.json');
    return List<Map<String, dynamic>>.from(
      json['rooms'] as List,
    ).map(RoomItem.fromJson).toList();
  }

  Future<List<DeviceItem>> loadDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_deviceKey);
    if (saved != null && saved.isNotEmpty) {
      return List<Map<String, dynamic>>.from(
        jsonDecode(saved) as List,
      ).map(DeviceItem.fromJson).toList();
    }
    final json = await _loadAsset('assets/deaf_mode/control.json');
    return List<Map<String, dynamic>>.from(
      json['devices'] as List,
    ).map(DeviceItem.fromJson).toList();
  }

  Future<void> saveDevices(List<DeviceItem> data) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = data
        .map(
          (e) => {'name': e.name, 'room': e.room, 'icon': e.icon, 'on': e.on},
        )
        .toList();
    await prefs.setString(_deviceKey, jsonEncode(payload));
  }

  Future<UserProfile> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_profileKey);
    if (raw == null || raw.isEmpty) {
      final json = await _loadAsset('assets/deaf_mode/profile.json');
      return UserProfile.fromJson(json);
    }
    return UserProfile.fromJson(
      Map<String, dynamic>.from(jsonDecode(raw) as Map),
    );
  }

  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }
}
