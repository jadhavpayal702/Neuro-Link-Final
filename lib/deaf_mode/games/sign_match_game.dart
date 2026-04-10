import 'dart:math';
import 'package:flutter/material.dart';
import 'package:neuro_link/deaf_mode/models/game_result_model.dart';
import 'package:neuro_link/deaf_mode/widgets/deaf_theme.dart';

class SignMatchGame extends StatefulWidget {
  final Function(GameResult) onComplete;
  final String difficulty; // easy, medium, hard

  const SignMatchGame({
    super.key, 
    required this.onComplete,
    this.difficulty = 'easy',
  });

  @override
  State<SignMatchGame> createState() => _SignMatchGameState();
}

class _SignMatchGameState extends State<SignMatchGame> {
  final Map<String, String> _signs = {
    '🤟': 'I Love You',
    '👍': 'Good',
    '👋': 'Hello',
    '🙏': 'Please',
    '👌': 'Okay',
    '✋': 'Stop',
    '👏': 'Perfect',
    '👊': 'Strength',
  };

  late String _currentSign;
  late List<String> _options;
  int _score = 0;
  int _questionsCount = 0;
  final int _totalQuestions = 10;
  int _moves = 0;
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
      _currentSign = _signs.keys.elementAt(Random().nextInt(_signs.length));
      
      int optionsCount = widget.difficulty == 'easy' ? 2 : (widget.difficulty == 'medium' ? 4 : 6);
      
      List<String> allLabels = _signs.values.toList();
      String correctLabel = _signs[_currentSign]!;
      allLabels.remove(correctLabel);
      allLabels.shuffle();
      
      _options = allLabels.take(optionsCount - 1).toList();
      _options.add(correctLabel);
      _options.shuffle();
      
      _questionsCount++;
    });
  }

  void _handleOption(String label) {
    _moves++;
    if (label == _signs[_currentSign]) {
      _score += 100;
    }
    _nextQuestion();
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
        title: const Text('Sign Match'),
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
            const SizedBox(height: 32),
            Text(
              'Question $_questionsCount/$_totalQuestions',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                  )
                ],
              ),
              alignment: Alignment.center,
              child: Text(_currentSign, style: const TextStyle(fontSize: 80)),
            ),
            const SizedBox(height: 48),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: _options.map((opt) => ElevatedButton(
                  onPressed: () => _handleOption(opt),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(opt, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
