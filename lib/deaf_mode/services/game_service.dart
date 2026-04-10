import '../models/game_result_model.dart';

class GameService {
  static const int baseScorePerMove = 100;
  static const int timePenaltyThreshold = 30; // seconds

  int calculatePoints(String gameId, GameResult result) {
    // Basic scoring logic
    // More accuracy + less time = more points
    double timeMultiplier = result.timeTaken > timePenaltyThreshold ? 0.8 : 1.2;
    int points = (result.score * result.accuracy * timeMultiplier).toInt();
    
    // Ensure minimum points for playing
    return points > 0 ? points : 10;
  }

  List<String> checkAchievements(int totalPoints, int gamesPlayed) {
    List<String> newlyUnlocked = [];

    if (totalPoints >= 500 && totalPoints < 500 + 100) { // Check roughly around threshold
       // In a real app we'd check if they already have it
       // But the FireStore arrayUnion handles duplicates
       newlyUnlocked.add('Beginner');
    }
    if (totalPoints >= 2000) {
      newlyUnlocked.add('Pro');
    }
    if (gamesPlayed >= 5) {
      newlyUnlocked.add('Explorer');
    }

    return newlyUnlocked;
  }
}
