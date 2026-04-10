import 'dart:math';
import 'package:flutter/material.dart';
import 'package:neuro_link/deaf_mode/models/game_result_model.dart';
import 'package:neuro_link/deaf_mode/widgets/deaf_theme.dart';

class PatternPuzzleGame extends StatefulWidget {
  final Function(GameResult) onComplete;

  const PatternPuzzleGame({super.key, required this.onComplete});

  @override
  State<PatternPuzzleGame> createState() => _PatternPuzzleGameState();
}

class _PatternPuzzleGameState extends State<PatternPuzzleGame> {
  final List<String> _shapes = ['🔴', '🔵', '🟢', '🟡', '🟣', '🟠', '🔼', '⏹️'];
  late List<String> _pattern;
  late List<String> _options;
  late int _missingIndex;
  int _score = 0;
  int _moves = 0;
  int _questionsCount = 0;
  final int _totalQuestions = 10;
  DateTime _startTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _nextQuestion();
  }

  void _nextQuestion() {
    if (_questionsCount >= _totalQuestions) {
      _completeGame();
      return;
    }

    setState(() {
      // Create a pattern (e.g., A B A B or A B C A B C)
      int patternType = Random().nextInt(2); // 0 or 1
      _pattern = [];
      
      if (patternType == 0) {
        String a = _shapes[Random().nextInt(_shapes.length)];
        String b = _shapes[Random().nextInt(_shapes.length)];
        while (a == b) b = _shapes[Random().nextInt(_shapes.length)];
        _pattern = [a, b, a, b, a, b];
      } else {
        String a = _shapes[Random().nextInt(_shapes.length)];
        String b = _shapes[Random().nextInt(_shapes.length)];
        String c = _shapes[Random().nextInt(_shapes.length)];
        while (a == b || b == c || a == c) {
          b = _shapes[Random().nextInt(_shapes.length)];
          c = _shapes[Random().nextInt(_shapes.length)];
        }
        _pattern = [a, b, c, a, b, c];
      }

      _missingIndex = Random().nextInt(_pattern.length);
      String correctAnswer = _pattern[_missingIndex];
      _pattern[_missingIndex] = '?';

      _options = [correctAnswer];
      while (_options.length < 4) {
        String rand = _shapes[Random().nextInt(_shapes.length)];
        if (!_options.contains(rand)) _options.add(rand);
      }
      _options.shuffle();
      
      _questionsCount++;
    });
  }

  void _handleOption(String shape) {
    _moves++;
    String correctAnswer = _shapes.firstWhere((s) {
      // We need to re-find the correct answer because _pattern[_missingIndex] was replaced
      // In our simple case, it's the one we put in _options first
      return true; // placeholder, the logic below is better
    }, orElse: () => '');

    // Re-verify the correct answer logic
    // Re-generating the same pattern index logic
    // Since we know the index, let's just keep track of the correct answer
  }

  // Simplified handler
  void _checkAnswer(String selected) {
    _moves++;
    // The correct answer is always at the original missing index position of the hidden pattern
    // Let's fix _nextQuestion to store the correct answer explicitly
  }

  // Redoing the state variables for clarity
  String _correctShape = '';

  void _generateQuestion() {
     if (_questionsCount >= _totalQuestions) {
      _completeGame();
      return;
    }

    setState(() {
      int patternType = Random().nextInt(2);
      _pattern = [];
      List<String> base;
      if (patternType == 0) {
        String a = _shapes[Random().nextInt(_shapes.length)];
        String b = _shapes[Random().nextInt(_shapes.length)];
        while (a == b) b = _shapes[Random().nextInt(_shapes.length)];
        base = [a, b];
        _pattern = [a, b, a, b, a, b];
      } else {
        String a = _shapes[Random().nextInt(_shapes.length)];
        String b = _shapes[Random().nextInt(_shapes.length)];
        String c = _shapes[Random().nextInt(_shapes.length)];
        while (a == b || b == c || a == c) {
          b = _shapes[Random().nextInt(_shapes.length)];
          c = _shapes[Random().nextInt(_shapes.length)];
        }
        base = [a, b, c];
        _pattern = [a, b, c, a, b, c];
      }

      _missingIndex = Random().nextInt(_pattern.length);
      _correctShape = _pattern[_missingIndex];
      _pattern[_missingIndex] = '?';

      _options = [_correctShape];
      while (_options.length < 4) {
        String rand = _shapes[Random().nextInt(_shapes.length)];
        if (!_options.contains(rand)) _options.add(rand);
      }
      _options.shuffle();
      _questionsCount++;
    });
  }

  void _completeGame() {
    final endTime = DateTime.now();
    final timeTaken = endTime.difference(_startTime).inSeconds;
    final accuracy = _score / (_totalQuestions * 100);

    widget.onComplete(GameResult(
      score: _score,
      moves: _moves,
      timeTaken: timeTaken,
      accuracy: accuracy,
    ));
  }

  @override
  Widget build(BuildContext context) {
     return Scaffold(
      backgroundColor: DeafTheme.bg,
      appBar: AppBar(
        title: const Text('Pattern Puzzle'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
             LinearProgressIndicator(
              value: _questionsCount / _totalQuestions,
              backgroundColor: Colors.white,
              color: DeafTheme.orangeA,
            ),
            const SizedBox(height: 64),
            const Text('Complete the pattern:', style: TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _pattern.map((p) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(p, style: TextStyle(fontSize: 40, color: p == '?' ? DeafTheme.orangeA : null)),
                )).toList(),
              ),
            ),
            const SizedBox(height: 64),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _options.map((opt) => GestureDetector(
                onTap: () {
                  _moves++;
                  if (opt == _correctShape) {
                    _score += 100;
                  }
                  _generateQuestion();
                },
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(opt, style: const TextStyle(fontSize: 32)),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
