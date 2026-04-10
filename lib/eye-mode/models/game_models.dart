import 'package:flutter/material.dart';

class PictureMatchCard {
  final int id;
  final IconData icon;
  bool isFlipped;
  bool isMatched;

  PictureMatchCard({
    required this.id,
    required this.icon,
    this.isFlipped = false,
    this.isMatched = false,
  });
}

class LetterBubble {
  final String letter;
  double x;
  double y;
  double vx;
  double vy;
  double speed;

  LetterBubble({
    required this.letter,
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    this.speed = 0.005,
  });
}

class WordPuzzle {
  final String word;
  final IconData icon;

  WordPuzzle({required this.word, required this.icon});
}
