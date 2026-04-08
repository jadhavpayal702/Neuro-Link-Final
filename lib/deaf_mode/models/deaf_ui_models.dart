class CourseItem {
  CourseItem({
    required this.id,
    required this.title,
    required this.lessons,
    required this.progress,
    required this.icon,
  });

  final String id;
  final String title;
  final int lessons;
  final double progress;
  final String icon;

  factory CourseItem.fromJson(Map<String, dynamic> json) => CourseItem(
    id: json['id'] as String,
    title: json['title'] as String,
    lessons: (json['lessons'] as num).toInt(),
    progress: (json['progress'] as num).toDouble(),
    icon: json['icon'] as String,
  );
}

class VideoItem {
  VideoItem({
    required this.title,
    required this.duration,
    required this.thumbnail,
    required this.captions,
  });

  final String title;
  final String duration;
  final String thumbnail;
  final bool captions;

  factory VideoItem.fromJson(Map<String, dynamic> json) => VideoItem(
    title: json['title'] as String,
    duration: json['duration'] as String,
    thumbnail: json['thumbnail'] as String,
    captions: json['captions'] as bool,
  );
}

class ChatItem {
  ChatItem({
    required this.sender,
    required this.message,
    required this.time,
    required this.isUser,
  });

  final String sender;
  final String message;
  final String time;
  final bool isUser;

  factory ChatItem.fromJson(Map<String, dynamic> json) => ChatItem(
    sender: json['sender'] as String,
    message: json['message'] as String,
    time: json['time'] as String,
    isUser: json['isUser'] as bool,
  );
}

class GameItem {
  GameItem({
    required this.title,
    required this.subtitle,
    required this.level,
    required this.points,
    required this.emoji,
  });

  final String title;
  final String subtitle;
  final String level;
  final int points;
  final String emoji;

  factory GameItem.fromJson(Map<String, dynamic> json) => GameItem(
    title: json['title'] as String,
    subtitle: json['subtitle'] as String,
    level: json['level'] as String,
    points: (json['points'] as num).toInt(),
    emoji: json['emoji'] as String,
  );
}

class RoomItem {
  RoomItem({
    required this.title,
    required this.description,
    required this.members,
    required this.online,
    required this.emoji,
  });

  final String title;
  final String description;
  final int members;
  final int online;
  final String emoji;

  factory RoomItem.fromJson(Map<String, dynamic> json) => RoomItem(
    title: json['title'] as String,
    description: json['description'] as String,
    members: (json['members'] as num).toInt(),
    online: (json['online'] as num).toInt(),
    emoji: json['emoji'] as String,
  );
}

class DeviceItem {
  DeviceItem({
    required this.name,
    required this.room,
    required this.icon,
    required this.on,
  });

  final String name;
  final String room;
  final String icon;
  bool on;

  factory DeviceItem.fromJson(Map<String, dynamic> json) => DeviceItem(
    name: json['name'] as String,
    room: json['room'] as String,
    icon: json['icon'] as String,
    on: json['on'] as bool,
  );
}

class UserProfile {
  UserProfile({required this.name, required this.email, required this.phone});

  final String name;
  final String email;
  final String phone;

  UserProfile copyWith({String? name, String? email, String? phone}) =>
      UserProfile(
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
      );

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'] as String? ?? '',
    email: json['email'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
  );
}
