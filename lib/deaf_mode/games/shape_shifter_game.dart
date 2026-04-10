import 'package:flutter/material.dart';
import 'package:neuro_link/deaf_mode/models/game_result_model.dart';
import 'package:neuro_link/deaf_mode/widgets/deaf_theme.dart';

class ShapeShifterGame extends StatefulWidget {
  final Function(GameResult) onComplete;

  const ShapeShifterGame({super.key, required this.onComplete});

  @override
  State<ShapeShifterGame> createState() => _ShapeShifterGameState();
}

class _ShapeShifterGameState extends State<ShapeShifterGame> {
  final List<Map<String, dynamic>> _allShapes = [
    {'icon': Icons.circle, 'name': 'Circle', 'color': Colors.red},
    {'icon': Icons.square, 'name': 'Square', 'color': Colors.blue},
    {'icon': Icons.change_history, 'name': 'Triangle', 'color': Colors.green},
    {'icon': Icons.star, 'name': 'Star', 'color': Colors.yellow},
    {'icon': Icons.rectangle, 'name': 'Rectangle', 'color': Colors.purple},
    {'icon': Icons.favorite, 'name': 'Heart', 'color': Colors.pink},
  ];

  late List<Map<String, dynamic>> _currentShapes;
  late Map<String, bool> _scoreMap;
  int _score = 0;
  int _moves = 0;
  DateTime _startTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _startNewRound();
  }

  void _startNewRound() {
    setState(() {
      _currentShapes = List.from(_allShapes)..shuffle();
      _currentShapes = _currentShapes.take(4).toList();
      _scoreMap = {for (var s in _currentShapes) s['name']: false};
    });
  }

  void _completeGame() {
    final endTime = DateTime.now();
    final timeTaken = endTime.difference(_startTime).inSeconds;
    final accuracy = (_score / 1200).clamp(0.0, 1.0);

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
        title: const Text('Shape Shifter'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text('Drag the shape to its outline!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _currentShapes.map((shape) {
                return Draggable<String>(
                  data: shape['name'],
                  feedback: Icon(shape['icon'], size: 70, color: shape['color']),
                  childWhenDragging: Icon(shape['icon'], size: 60, color: Colors.grey.withValues(alpha: 0.3)),
                  child: _scoreMap[shape['name']] == true
                      ? const SizedBox(width: 60, height: 60)
                      : Icon(shape['icon'], size: 60, color: shape['color']),
                );
              }).toList(),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _currentShapes.map((shape) {
                return DragTarget<String>(
                  onWillAccept: (data) => data == shape['name'],
                  onAccept: (data) {
                    setState(() {
                      _scoreMap[shape['name']] = true;
                      _score += 300;
                      _moves++;
                    });
                    if (_scoreMap.values.every((v) => v)) {
                      _completeGame();
                    }
                  },
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _scoreMap[shape['name']] == true 
                            ? shape['color'] 
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: candidateData.isNotEmpty ? shape['color'] : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        shape['icon'],
                        size: 50,
                        color: _scoreMap[shape['name']] == true 
                            ? Colors.white 
                            : Colors.grey.withValues(alpha: 0.2),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
