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
      {'title': 'Word Builder', 'icon': Icons.abc_rounded, 'desc': 'Construct words from bubbles'},
      {'title': 'Picture Match', 'icon': Icons.dashboard_customize_rounded, 'desc': 'Test your memory pairs'},
      {'title': 'Spell It', 'icon': Icons.spellcheck_rounded, 'desc': 'Identify images and spell'},
      {'title': 'Find Word', 'icon': Icons.search_rounded, 'desc': 'Discover hidden words'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.only(bottom: 20),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: games.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.8, // Shorter cards
              ),
              itemBuilder: (context, index) {
                final game = games[index];
                return focusableBuilder(
                  index: index,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => onGameSelected(index),
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF6A00).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(game['icon'] as IconData, size: 24, color: const Color(0xFFFF6A00)),
                              ),
                              const Spacer(),
                              Text(
                                game['title'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                game['desc'] as String,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 12,
                                  height: 1.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
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
