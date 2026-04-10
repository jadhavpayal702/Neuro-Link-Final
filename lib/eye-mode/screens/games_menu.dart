import 'package:flutter/material.dart';

typedef FocusableBuilder = Widget Function({required int index, required Widget child});

class GamesMenu extends StatelessWidget {
  final FocusableBuilder focusableBuilder;
  final int focusIndex;
  final Function(int gameIndex) onGameSelected;

  const GamesMenu({
    super.key,
    required this.focusableBuilder,
    required this.focusIndex,
    required this.onGameSelected,
  });

  @override
  Widget build(BuildContext context) {
    final games = [
      {'title': 'Word Builder', 'icon': Icons.abc, 'desc': 'Construct words from floating bubbles'},
      {'title': 'Picture Match', 'icon': Icons.dashboard_customize_outlined, 'desc': 'Test your memory with matching pairs'},
      {'title': 'Spell It', 'icon': Icons.spellcheck_rounded, 'desc': 'Identify images and spell their names'},
      {'title': 'Find Word', 'icon': Icons.search_rounded, 'desc': 'Discover hidden words in the grid'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const Text(
            'Select a Game',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: games.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.95,
              ),
              itemBuilder: (context, index) {
                final game = games[index];
                final isFocused = focusIndex == index;

                return focusableBuilder(
                  index: index,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isFocused ? const Color(0xFFFF6A00) : const Color(0xFF2A2A2A),
                        width: isFocused ? 3 : 1.5,
                      ),
                      boxShadow: isFocused
                          ? [
                              BoxShadow(
                                color: const Color(0xFFFF6A00).withValues(alpha: 0.3),
                                blurRadius: 20,
                              )
                            ]
                          : [],
                    ),
                    child: InkWell(
                      onTap: () => onGameSelected(index),
                      borderRadius: BorderRadius.circular(24),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              game['icon'] as IconData,
                              size: 56,
                              color: isFocused ? const Color(0xFFFF6A00) : Colors.white70,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              game['title'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              game['desc'] as String,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
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
