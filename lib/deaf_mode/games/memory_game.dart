import 'dart:async';
import 'package:flutter/material.dart';
import 'package:neuro_link/deaf_mode/models/game_result_model.dart';
import 'package:neuro_link/deaf_mode/widgets/deaf_theme.dart';

class MemoryGame extends StatefulWidget {
  final Function(GameResult) onComplete;

  const MemoryGame({super.key, required this.onComplete});

  @override
  State<MemoryGame> createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {
  final List<String> _emojis = ['🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼'];
  late List<String> _cards;
  late List<bool> _flipped;
  late List<bool> _matched;
  int? _firstIndex;
  int _moves = 0;
  int _matches = 0;
  DateTime _startTime = DateTime.now();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    _cards = [..._emojis, ..._emojis]..shuffle();
    _flipped = List.filled(_cards.length, false);
    _matched = List.filled(_cards.length, false);
    _firstIndex = null;
    _moves = 0;
    _matches = 0;
    _startTime = DateTime.now();
    _busy = false;
  }

  void _handleTap(int index) {
    if (_busy || _flipped[index] || _matched[index]) return;

    setState(() {
      _flipped[index] = true;
    });

    if (_firstIndex == null) {
      _firstIndex = index;
    } else {
      _moves++;
      _busy = true;
      if (_cards[_firstIndex!] == _cards[index]) {
        _matched[_firstIndex!] = true;
        _matched[index] = true;
        _matches++;
        _firstIndex = null;
        _busy = false;
        if (_matches == _emojis.length) {
          _completeGame();
        }
      } else {
        Timer(const Duration(milliseconds: 1000), () {
          setState(() {
            _flipped[_firstIndex!] = false;
            _flipped[index] = false;
            _firstIndex = null;
            _busy = false;
          });
        });
      }
    }
  }

  void _completeGame() {
    final endTime = DateTime.now();
    final timeTaken = endTime.difference(_startTime).inSeconds;
    final accuracy = (_emojis.length / _moves).clamp(0.0, 1.0);
    
    widget.onComplete(GameResult(
      score: 1000 - (_moves * 10),
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
        title: const Text('Memory Match'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statCard('Moves', '$_moves'),
                _statCard('Matches', '$_matches/${_emojis.length}'),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _cards.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, i) {
                return GestureDetector(
                  onTap: () => _handleTap(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: (_flipped[i] || _matched[i]) ? Colors.white : DeafTheme.orangeA,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        if (!(_flipped[i] || _matched[i]))
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: (_flipped[i] || _matched[i])
                        ? Text(_cards[i], style: const TextStyle(fontSize: 32))
                        : const Icon(Icons.help_outline, color: Colors.white, size: 32),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }
}
