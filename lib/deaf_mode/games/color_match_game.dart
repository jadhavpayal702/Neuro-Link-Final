import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:neuro_link/deaf_mode/models/game_result_model.dart';
import 'package:neuro_link/deaf_mode/widgets/deaf_theme.dart';

class ColorMatchGame extends StatefulWidget {
  final Function(GameResult) onComplete;

  const ColorMatchGame({super.key, required this.onComplete});

  @override
  State<ColorMatchGame> createState() => _ColorMatchGameState();
}

class _ColorMatchGameState extends State<ColorMatchGame> {
  final List<Color> _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
  ];

  List<int> _sequence = [];
  List<int> _userSequence = [];
  bool _showingSequence = false;
  int _score = 0;
  int _level = 1;
  int _activeColorIndex = -1;
  DateTime _startTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _startNextLevel();
  }

  void _startNextLevel() {
    setState(() {
      _sequence.add(Random().nextInt(_colors.length));
      _userSequence = [];
      _showingSequence = true;
    });
    _playSequence();
  }

  Future<void> _playSequence() async {
    for (int index in _sequence) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      setState(() => _activeColorIndex = index);
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      setState(() => _activeColorIndex = -1);
    }
    setState(() => _showingSequence = false);
  }

  void _handleColorTap(int index) {
    if (_showingSequence) return;

    setState(() {
      _userSequence.add(index);
    });

    if (_userSequence[(_userSequence.length - 1)] != _sequence[(_userSequence.length - 1)]) {
      _completeGame();
    } else if (_userSequence.length == _sequence.length) {
      _score += _level * 100;
      _level++;
      Timer(const Duration(milliseconds: 500), _startNextLevel);
    }
  }

  void _completeGame() {
    final endTime = DateTime.now();
    final timeTaken = endTime.difference(_startTime).inSeconds;
    final accuracy = (_level / 10).clamp(0.0, 1.0); // Simple metric

    widget.onComplete(GameResult(
      score: _score,
      moves: _sequence.length,
      timeTaken: timeTaken,
      accuracy: accuracy,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DeafTheme.bg,
      appBar: AppBar(
        title: const Text('Color Match'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Level $_level', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text(
              _showingSequence ? 'Watch Carefully...' : 'Repeat the Pattern!',
              style: TextStyle(color: _showingSequence ? DeafTheme.orangeA : Colors.green, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: 300,
              height: 300,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 4,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemBuilder: (context, i) {
                  bool isActive = _activeColorIndex == i;
                  return GestureDetector(
                    onTapDown: (_) => setState(() => _activeColorIndex = i),
                    onTapUp: (_) => setState(() => _activeColorIndex = -1),
                    onTapCancel: () => setState(() => _activeColorIndex = -1),
                    onTap: () => _handleColorTap(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      decoration: BoxDecoration(
                        color: _colors[i].withValues(alpha: isActive ? 1.0 : 0.4),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isActive ? Colors.white : Colors.transparent,
                          width: 4,
                        ),
                        boxShadow: isActive ? [
                          BoxShadow(color: _colors[i].withValues(alpha: 0.5), blurRadius: 20, spreadRadius: 5)
                        ] : [],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
