import 'dart:async';
import 'package:flutter/material.dart';
import '../models/game_models.dart';

typedef FocusableBuilder = Widget Function({required int index, required Widget child});

class GamePictureMatch extends StatefulWidget {
  final FocusableBuilder focusableBuilder;
  final int focusIndex;
  final ValueNotifier<int?> selectTrigger;
  final VoidCallback onWin;

  const GamePictureMatch({
    super.key,
    required this.focusableBuilder,
    required this.focusIndex,
    required this.selectTrigger,
    required this.onWin,
  });

  @override
  State<GamePictureMatch> createState() => _GamePictureMatchState();
}

class _GamePictureMatchState extends State<GamePictureMatch> {
  List<PictureMatchCard> cards = [];
  int? firstFlippedIdx;
  bool processing = false;

  final List<IconData> availableIcons = [
    Icons.wb_sunny, Icons.wb_cloudy, Icons.pets,
    Icons.fastfood, Icons.directions_car, Icons.airplanemode_active,
  ];

  @override
  void initState() {
    super.initState();
    _initGame();
    widget.selectTrigger.addListener(_onRemoteSelect);
  }

  void _onRemoteSelect() {
    if (!mounted || widget.selectTrigger.value == null) return;
    final idx = widget.selectTrigger.value!;
    if (idx >= 0 && idx < cards.length) {
      _onCardSelect(idx);
    }
  }

  @override
  void dispose() {
    widget.selectTrigger.removeListener(_onRemoteSelect);
    super.dispose();
  }

  void _initGame() {
    final icons = [...availableIcons, ...availableIcons]..shuffle();
    cards = List.generate(icons.length, (i) => PictureMatchCard(id: i, icon: icons[i]));
  }

  void _onCardSelect(int index) {
    if (processing || cards[index].isFlipped || cards[index].isMatched) return;

    setState(() {
      cards[index].isFlipped = true;
    });

    if (firstFlippedIdx == null) {
      firstFlippedIdx = index;
    } else {
      processing = true;
      final first = cards[firstFlippedIdx!];
      final second = cards[index];

      if (first.icon == second.icon) {
        first.isMatched = true;
        second.isMatched = true;
        firstFlippedIdx = null;
        processing = false;
        if (cards.every((c) => c.isMatched)) {
          widget.onWin();
        }
      } else {
        Timer(const Duration(milliseconds: 1000), () {
          if (!mounted) return;
          setState(() {
            first.isFlipped = false;
            second.isFlipped = false;
            firstFlippedIdx = null;
            processing = false;
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'PICTURE MATCH',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              itemCount: cards.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemBuilder: (context, index) {
                final card = cards[index];
                final isFocused = widget.focusIndex == index;

                return widget.focusableBuilder(
                  index: index,
                  child: GestureDetector(
                    onTap: () => _onCardSelect(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOutBack,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isFocused ? const Color(0xFFFF6A00) : const Color(0xFF2A2A2A),
                          width: isFocused ? 3 : 1.5,
                        ),
                      ),
                      child: Center(
                        child: card.isFlipped || card.isMatched
                            ? Icon(card.icon, color: card.isMatched ? Colors.green : const Color(0xFFFF6A00), size: 48)
                            : const Icon(Icons.help_outline, color: Colors.white24, size: 32),
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
