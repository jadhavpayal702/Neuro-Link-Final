import 'package:flutter/material.dart';

class CounterText extends StatelessWidget {
  final int value;
  final TextStyle style;

  const CounterText({super.key, required this.value, required this.style});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      duration: const Duration(seconds: 2),
      curve: Curves.easeOutQuart,
      builder: (context, val, child) {
        return Text(
          val.toInt().toString(),
          style: style,
        );
      },
    );
  }
}
