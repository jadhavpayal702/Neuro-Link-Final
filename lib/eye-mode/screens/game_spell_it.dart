import 'package:flutter/material.dart';

typedef FocusableBuilder = Widget Function({required int index, required Widget child});

class GameSpellIt extends StatefulWidget {
  final FocusableBuilder focusableBuilder;
  final int focusIndex;
  final VoidCallback onWin;

  const GameSpellIt({
    super.key,
    required this.focusableBuilder,
    required this.focusIndex,
    required this.onWin,
  });

  @override
  State<GameSpellIt> createState() => _GameSpellItState();
}

class _GameSpellItState extends State<GameSpellIt> {
  final List<Map<String, dynamic>> puzzles = [
    {'word': 'CAT', 'icon': Icons.pets},
    {'word': 'SUN', 'icon': Icons.wb_sunny},
    {'word': 'CAR', 'icon': Icons.directions_car},
  ];
  int currentIdx = 0;
  String currentInput = "";
  final List<String> letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".split('');

  void _onLetterSelect(String letter) {
    final target = puzzles[currentIdx]['word'] as String;
    setState(() {
      if (target.startsWith(currentInput + letter)) {
        currentInput += letter;
        if (currentInput == target) {
          if (currentIdx < puzzles.length - 1) {
            currentIdx++;
            currentInput = "";
          } else {
            widget.onWin();
          }
        }
      } else {
        currentInput = "";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final target = puzzles[currentIdx]['word'] as String;
    final icon = puzzles[currentIdx]['icon'] as IconData;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Image / Icon Prompt
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: Icon(icon, size: 80, color: const Color(0xFFFF6A00)),
          ),
          const SizedBox(height: 20),
          // Slots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(target.length, (i) {
              final val = i < currentInput.length ? currentInput[i] : "";
              return Container(
                width: 44,
                height: 54,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: val.isNotEmpty ? const Color(0xFFFF6A00) : Colors.white24, width: 3)),
                ),
                alignment: Alignment.center,
                child: Text(val, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              );
            }),
          ),
          const SizedBox(height: 20),
          // Letter Grid
          Expanded(
            child: GridView.builder(
              itemCount: letters.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemBuilder: (context, index) {
                final letter = letters[index];
                final isFocused = widget.focusIndex == index;
                return widget.focusableBuilder(
                  index: index,
                  child: GestureDetector(
                    onTap: () => _onLetterSelect(letter),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        color: isFocused ? const Color(0xFFFF6A00) : const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF2A2A2A)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        letter,
                        style: TextStyle(color: isFocused ? Colors.black : Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
