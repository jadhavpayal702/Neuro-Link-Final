import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neuro_link/deaf_mode/models/user_model.dart';
import 'package:neuro_link/deaf_mode/models/game_result_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // User related
  Future<void> saveUserProfile(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap(), SetOptions(merge: true));
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Stream<UserModel?> streamUserProfile(String uid) {
    if (uid.isEmpty) return Stream.value(null);
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }

  Stream<List<UserModel>> getUsersDiscovery(String currentUserUid) {
    return _db.collection('users')
        .where('profileCompleted', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .where((doc) => doc.id != currentUserUid)
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Game related
  Future<void> saveGameStats(String uid, String gameId, GameResult result) async {
    final docRef = _db.collection('game_stats').doc('${uid}_$gameId');
    final doc = await docRef.get();
    
    int highScore = result.score;
    int attempts = 1;
    double avgAccuracy = result.accuracy;

    if (doc.exists) {
      final data = doc.data()!;
      highScore = highScore > (data['highScore'] ?? 0) ? highScore : (data['highScore'] ?? 0);
      attempts = (data['attempts'] ?? 0) + 1;
      avgAccuracy = ((data['accuracy'] ?? 0.0) * (attempts - 1) + result.accuracy) / attempts;
    }

    await docRef.set({
      'userId': uid,
      'gameId': gameId,
      'highScore': highScore,
      'attempts': attempts,
      'accuracy': avgAccuracy,
      'lastPlayed': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updateUserProgress(String uid, {
    int? addPoints,
    bool incrementGames = false,
    int? newStreak,
    List<String>? newAchievements,
  }) async {
    final Map<String, dynamic> updates = {
      'updatedAt': FieldValue.serverTimestamp(),
      'lastPlayed': FieldValue.serverTimestamp(),
    };

    if (addPoints != null) {
      updates['points'] = FieldValue.increment(addPoints);
    }
    if (incrementGames) {
      updates['gamesPlayed'] = FieldValue.increment(1);
    }
    if (newStreak != null) {
      updates['streak'] = newStreak;
    }
    if (newAchievements != null) {
      updates['achievements'] = FieldValue.arrayUnion(newAchievements);
    }

    await _db.collection('users').doc(uid).update(updates);
  }
}
