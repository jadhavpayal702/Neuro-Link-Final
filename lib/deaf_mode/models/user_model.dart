import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String place;
  final String city;
  final String profileEmoji;
  final bool profileCompleted;
  
  // Progress Fields
  final int points;
  final int gamesPlayed;
  final List<String> achievements;
  final int streak;
  final DateTime? lastPlayed;
  
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.place,
    required this.city,
    required this.profileEmoji,
    this.profileCompleted = false,
    this.points = 0,
    this.gamesPlayed = 0,
    this.achievements = const [],
    this.streak = 0,
    this.lastPlayed,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'place': place,
      'city': city,
      'profileEmoji': profileEmoji,
      'profileCompleted': profileCompleted,
      'points': points,
      'gamesPlayed': gamesPlayed,
      'achievements': achievements,
      'streak': streak,
      'lastPlayed': lastPlayed != null ? Timestamp.fromDate(lastPlayed!) : null,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      place: map['place'] ?? '',
      city: map['city'] ?? '',
      profileEmoji: map['profileEmoji'] ?? '',
      profileCompleted: map['profileCompleted'] ?? false,
      points: map['points'] ?? 0,
      gamesPlayed: map['gamesPlayed'] ?? 0,
      achievements: List<String>.from(map['achievements'] ?? []),
      streak: map['streak'] ?? 0,
      lastPlayed: (map['lastPlayed'] as Timestamp?)?.toDate(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
