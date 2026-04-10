import 'package:cloud_firestore/cloud_firestore.dart';

class StoryModel {
  final String id;
  final String userId;
  final String userName;
  final String userEmoji;
  final StoryData storyData;
  final DateTime createdAt;
  final DateTime expiresAt;

  StoryModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmoji,
    required this.storyData,
    required this.createdAt,
    required this.expiresAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmoji': userEmoji,
      'storyData': storyData.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
    };
  }

  factory StoryModel.fromMap(Map<String, dynamic> map, String id) {
    return StoryModel(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userEmoji: map['userEmoji'] ?? '😊',
      storyData: StoryData.fromMap(map['storyData'] ?? {}),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      expiresAt: (map['expiresAt'] as Timestamp).toDate(),
    );
  }
}

class StoryData {
  final String text;
  final List<String> emojis;
  final String fontStyle;
  final double fontSize;
  final String textColor;
  final String backgroundColor;

  StoryData({
    required this.text,
    this.emojis = const [],
    this.fontStyle = 'normal',
    this.fontSize = 24,
    this.textColor = '#FFFFFF',
    this.backgroundColor = '#FF6A00',
  });

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'emojis': emojis,
      'fontStyle': fontStyle,
      'fontSize': fontSize,
      'textColor': textColor,
      'backgroundColor': backgroundColor,
    };
  }

  factory StoryData.fromMap(Map<String, dynamic> map) {
    return StoryData(
      text: map['text'] ?? '',
      emojis: List<String>.from(map['emojis'] ?? []),
      fontStyle: map['fontStyle'] ?? 'normal',
      fontSize: (map['fontSize'] ?? 24).toDouble(),
      textColor: map['textColor'] ?? '#FFFFFF',
      backgroundColor: map['backgroundColor'] ?? '#FF6A00',
    );
  }
}

class RoomModel {
  final String id;
  final String name;
  final String description;
  final String emoji; // Added for UI consistency with the screenshot
  final String createdBy;
  final List<String> members;
  final int totalMembers;
  final int activeMembers;
  final DateTime createdAt;

  RoomModel({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.createdBy,
    this.members = const [],
    this.totalMembers = 0,
    this.activeMembers = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'emoji': emoji,
      'createdBy': createdBy,
      'members': members,
      'totalMembers': totalMembers,
      'activeMembers': activeMembers,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory RoomModel.fromMap(Map<String, dynamic> map, String id) {
    return RoomModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      emoji: map['emoji'] ?? '👥',
      createdBy: map['createdBy'] ?? '',
      members: List<String>.from(map['members'] ?? []),
      totalMembers: map['totalMembers'] ?? 0,
      activeMembers: map['activeMembers'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}

class RoomMessageModel {
  final String id;
  final String userId;
  final String userName;
  final String userEmoji;
  final String text;
  final DateTime createdAt;

  RoomMessageModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmoji,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmoji': userEmoji,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory RoomMessageModel.fromMap(Map<String, dynamic> map, String id) {
    return RoomMessageModel(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userEmoji: map['userEmoji'] ?? '😊',
      text: map['text'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
