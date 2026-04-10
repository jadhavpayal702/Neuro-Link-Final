class GameResult {
  final int score;
  final int moves;
  final int timeTaken; // in seconds
  final double accuracy;

  GameResult({
    required this.score,
    required this.moves,
    required this.timeTaken,
    required this.accuracy,
  });

  Map<String, dynamic> toMap() {
    return {
      'score': score,
      'moves': moves,
      'timeTaken': timeTaken,
      'accuracy': accuracy,
    };
  }
}
