import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/community_models.dart';

class CommunityService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ROOMS
  Stream<List<RoomModel>> streamRooms() {
    return _db.collection('rooms')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => RoomModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> createRoom(RoomModel room) async {
    await _db.collection('rooms').add(room.toMap());
  }

  Future<void> joinRoom(String roomId, String userId) async {
    await _db.collection('rooms').doc(roomId).update({
      'members': FieldValue.arrayUnion([userId]),
      'totalMembers': FieldValue.increment(1),
    });
  }

  // ACTIVE MEMBERS LOGIC
  Future<void> updateActiveStatus(String roomId, String userId) async {
    await _db.collection('rooms')
        .doc(roomId)
        .collection('activity')
        .doc(userId)
        .set({
      'lastActiveAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<int> streamActiveMembersCount(String roomId) {
    // Defines active as within last 5 minutes
    final fiveMinutesAgo = DateTime.now().subtract(const Duration(minutes: 5));
    return _db.collection('rooms')
        .doc(roomId)
        .collection('activity')
        .where('lastActiveAt', isGreaterThanOrEqualTo: Timestamp.fromDate(fiveMinutesAgo))
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  // MESSAGES
  Stream<List<RoomMessageModel>> streamMessages(String roomId) {
    return _db.collection('rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => RoomMessageModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> sendMessage(String roomId, RoomMessageModel message) async {
    await _db.collection('rooms')
        .doc(roomId)
        .collection('messages')
        .add(message.toMap());
    
    // Also update activity when sending a message
    await updateActiveStatus(roomId, message.userId);
  }

  // STORIES
  Future<void> createStory(StoryModel story) async {
    await _db.collection('stories').add(story.toMap());
  }

  Stream<List<StoryModel>> streamStories() {
    final now = DateTime.now();
    return _db.collection('stories')
        .where('expiresAt', isGreaterThan: Timestamp.fromDate(now))
        .orderBy('expiresAt')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => StoryModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}
