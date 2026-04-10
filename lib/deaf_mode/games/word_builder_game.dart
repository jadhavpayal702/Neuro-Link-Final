import 'dart:math';
import 'package:flutter/material.dart';
import 'package:neuro_link/deaf_mode/models/game_result_model.dart';
import 'package:neuro_link/deaf_mode/widgets/deaf_theme.dart';

class WordBuilderGame extends StatefulWidget {
  final Function(GameResult) onComplete;

  const WordBuilderGame({super.key, required this.onComplete});

  @override
  State<WordBuilderGame> createState() => _WordBuilderGameState();
}

class _WordBuilderGameState extends State<WordBuilderGame> {
  final Map<String, List<String>> _words = {
    'APPLE': ['A', 'P', 'P', 'L', 'E'],
    'GRAPE': ['G', 'R', 'A', 'P', 'E'],
    'LEMON': ['L', 'E', 'M', 'O', 'N'],
    'BREAD': ['B', 'R', 'E', 'A', 'D'],
    'WATER': ['W', 'A', 'T', 'E', 'R'],
    'HOUSE': ['H', 'O', 'U', 'S', 'E'],
  };

  late String _currentWord;
  late List<String> _displayLetters;
  late int _missingIndex;
  late List<String> _options;
  int _score = 0;
  int _questionsCount = 0;
  final int _totalQuestions = 5;
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
      _currentWord = _words.keys.elementAt(Random().nextInt(_words.length));
      _displayLetters = List.from(_words[_currentWord]!);
      _missingIndex = Random().nextInt(_displayLetters.length);
      String correctLetter = _displayLetters[_missingIndex];
      _displayLetters[_missingIndex] = '_';

      _options = [correctLetter];
      while (_options.length < 4) {
        String rand = String.fromCharCode(Random().nextInt(26) + 65);
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
        title: const Text('Word Builder'),
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
            const SizedBox(height: 100),
            const Text('Which letter is missing?', style: TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _displayLetters.map((l) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 50,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: l == '_' ? Border.all(color: DeafTheme.orangeA, width: 2) : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  l,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: l == '_' ? DeafTheme.orangeA : Colors.black87,
                  ),
                ),
              )).toList(),
            ),
            const Spacer(),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: _options.map((opt) => ElevatedButton(
                onPressed: () {
                  _moves++;
                  if (opt == _words[_currentWord]![_missingIndex]) {
                    _score += 100;
                  }
                  _nextQuestion();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(opt, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              )).toList(),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
