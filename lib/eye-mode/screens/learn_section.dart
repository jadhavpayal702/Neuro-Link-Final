import 'package:flutter/material.dart';
import '../widgets/eye_category_card.dart';
import '../models/learn_data.dart';
import '../models/video.dart';

typedef FocusableBuilder = Widget Function({required int index, required Widget child});

class LearnSection extends StatelessWidget {
  final FocusableBuilder focusableBuilder;
  final int focusStartIndex;
  final int focusIndex;
  final Function(String category, List<Video> videos) onCategorySelected;

  const LearnSection({
    super.key,
    required this.focusableBuilder,
    required this.focusStartIndex,
    required this.focusIndex,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final categories = learnContent.keys.toList();
    final icons = [
      Icons.keyboard_alt_outlined,
      Icons.security_outlined,
      Icons.volunteer_activism_outlined,
      Icons.home_max_outlined,
      Icons.accessibility_new_rounded,
      Icons.air_rounded,
    ];
    final colors = [
      const Color(0xFF36C2FF),
      const Color(0xFF22C55E),
      const Color(0xFFF97316),
      const Color(0xFF7C3AED),
      const Color(0xFFEC4899),
      const Color(0xFF06B6D4),
    ];

    return Column(
      children: [
        const SizedBox(height: 10),
        Expanded(
          child: GridView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // Increased from 2
              crossAxisSpacing: 12, // Tighter spacing
              mainAxisSpacing: 12,
              childAspectRatio: 0.75, // Narrower for 3 columns
            ),
            itemBuilder: (context, index) {
              final cat = categories[index];
              final videosMapping = learnContent[cat]!;
              final videos = videosMapping.map((m) => Video.fromMap(m)).toList();

              return focusableBuilder(
                index: focusStartIndex + index,
                child: EyeCategoryCard(
                  title: cat,
                  icon: icons[index % icons.length],
                  color: colors[index % colors.length],
                  isFocused: focusIndex == (focusStartIndex + index),
                  onTap: () => onCategorySelected(cat, videos),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
