import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/game_models.dart';

typedef FocusableBuilder = Widget Function({required int index, required Widget child});

class GameWordBuilder extends StatefulWidget {
  final FocusableBuilder focusableBuilder;
  final int focusIndex;
  final ValueNotifier<int?> selectTrigger;
  final VoidCallback onWin;

  const GameWordBuilder({
    super.key,
    required this.focusableBuilder,
    required this.focusIndex,
    required this.selectTrigger,
    required this.onWin,
  });

  @override
  State<GameWordBuilder> createState() => _GameWordBuilderState();
}

class _GameWordBuilderState extends State<GameWordBuilder> {
  final List<String> targetWords = ["EYE", "BRAIN", "LINK"];
  int currentTargetIdx = 0;
  String currentInput = "";
  List<LetterBubble> bubbles = [];
  Timer? animationTimer;
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    _startAnimation();
    _generateBubbles();
    widget.selectTrigger.addListener(_onRemoteSelect);
  }

  void _onRemoteSelect() {
    if (!mounted || widget.selectTrigger.value == null) return;
    final idx = widget.selectTrigger.value!;
    if (idx >= 0 && idx < bubbles.length) {
      _onLetterSelect(idx);
    }
  }

  @override
  void dispose() {
    widget.selectTrigger.removeListener(_onRemoteSelect);
    animationTimer?.cancel();
    super.dispose();
  }

  void _generateBubbles() {
    bubbles.clear();
    final target = targetWords[currentTargetIdx];
    final letters = (target + "QWOPRST").split('')..shuffle();
    for (var i = 0; i < letters.length; i++) {
      bubbles.add(LetterBubble(
        letter: letters[i],
        x: 0.15 + random.nextDouble() * 0.7,
        y: 0.2 + random.nextDouble() * 0.5,
        vx: (random.nextDouble() - 0.5) * 0.008,
        vy: (random.nextDouble() - 0.5) * 0.008,
      ));
    }
  }

  void _startAnimation() {
    animationTimer = Timer.periodic(const Duration(milliseconds: 32), (timer) {
      if (!mounted) return;
      setState(() {
        for (var b in bubbles) {
          b.x += b.vx;
          b.y += b.vy;
          if (b.x < 0.05 || b.x > 0.95) b.vx *= -1;
          if (b.y < 0.1 || b.y > 0.8) b.vy *= -1;
        }
      });
    });
  }

  void _onLetterSelect(int index) {
    setState(() {
      final letter = bubbles[index].letter;
      final target = targetWords[currentTargetIdx];
      if (target.startsWith(currentInput + letter)) {
        currentInput += letter;
        if (currentInput == target) {
          if (currentTargetIdx < targetWords.length - 1) {
            currentTargetIdx++;
            currentInput = "";
            _generateBubbles();
          } else {
            widget.onWin();
          }
        }
      } else {
        currentInput = ""; // Reset on error
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final target = targetWords[currentTargetIdx];

    return Stack(
      children: [
        // Target Word UI
        Positioned(
          top: 30,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Text(
                'BUILD THE WORD',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(target.length, (i) {
                  final active = i < currentInput.length;
                  return Container(
                    width: 48,
                    height: 56,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: active ? const Color(0xFFFF6A00) : const Color(0xFF2A2A2A),
                        width: 2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      active ? target[i] : '',
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),

        // Letter Bubbles
        for (int i = 0; i < bubbles.length; i++)
          Positioned(
            left: bubbles[i].x * size.width - 40,
            top: bubbles[i].y * size.height - 40,
            child: widget.focusableBuilder(
              index: i,
              child: GestureDetector(
                onTap: () => _onLetterSelect(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1E1E1E),
                    border: Border.all(
                      color: widget.focusIndex == i ? const Color(0xFFFF6A00) : const Color(0xFF2A2A2A),
                      width: widget.focusIndex == i ? 3 : 1.5,
                    ),
                    boxShadow: widget.focusIndex == i
                        ? [BoxShadow(color: const Color(0xFFFF6A00).withValues(alpha: 0.3), blurRadius: 15)]
                        : [],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    bubbles[i].letter,
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
