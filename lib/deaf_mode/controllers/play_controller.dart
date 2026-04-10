import 'package:flutter/foundation.dart';
import 'package:neuro_link/deaf_mode/models/game_result_model.dart';
import 'package:neuro_link/deaf_mode/models/user_model.dart';
import 'package:neuro_link/deaf_mode/services/firestore_service.dart';
import 'package:neuro_link/deaf_mode/services/game_service.dart';

class PlayController extends ChangeNotifier {
  final FirestoreService _firestore;
  final GameService _gameService;
  final String uid;

  PlayController(this._firestore, this._gameService, this.uid);

  UserModel? _user;
  UserModel? get user => _user;

  bool _loading = false;
  bool get loading => _loading;

  Future<void> initialize() async {
    _loading = true;
    notifyListeners();
    _user = await _firestore.getUserProfile(uid);
    _loading = false;
    notifyListeners();
  }

  Future<List<String>> updateProgress(GameResult result, String gameId) async {
    if (_user == null) return [];

    final earnedPoints = _gameService.calculatePoints(gameId, result);
    final totalPoints = _user!.points + earnedPoints;
    final totalGames = _user!.gamesPlayed + 1;
    
    // Check achievements
    final allPossible = _gameService.checkAchievements(totalPoints, totalGames);
    final newAchievements = allPossible.where((a) => !_user!.achievements.contains(a)).toList();
    
    // Streak logic
    int newStreak = _user!.streak;
    final now = DateTime.now();
    if (_user!.lastPlayed != null) {
      final diff = now.difference(_user!.lastPlayed!).inDays;
      if (diff == 1) {
        newStreak++;
      } else if (diff > 1) {
        newStreak = 1;
      }
    } else {
      newStreak = 1;
    }

    // Save to Firestore
    await _firestore.saveGameStats(uid, gameId, result);
    await _firestore.updateUserProgress(
      uid,
      addPoints: earnedPoints,
      incrementGames: true,
      newStreak: newStreak,
      newAchievements: newAchievements,
    );

    // Update local state
    _user = await _firestore.getUserProfile(uid);
    notifyListeners();

    return newAchievements;
  }
}
