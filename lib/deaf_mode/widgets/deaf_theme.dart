import 'package:flutter/material.dart';

class DeafTheme {
  static const bg = Color(0xFFF8F2E8);
  static const card = Colors.white;
  static const orangeA = Color(0xFFFF6A00);
  static const orangeB = Color(0xFFD94900);
  static const accentPink = Color(0xFFE7008A);

  static const topGradient = LinearGradient(
    colors: [orangeA, orangeB],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
