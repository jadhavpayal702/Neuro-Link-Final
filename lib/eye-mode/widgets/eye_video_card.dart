import 'package:flutter/material.dart';

class EyeVideoCard extends StatelessWidget {
  final String title;
  final String description;
  final String views;
  final bool isFocused;
  final VoidCallback onTap;

  const EyeVideoCard({
    super.key,
    required this.title,
    required this.description,
    required this.views,
    required this.isFocused,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 4), // Reduced from 8
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04), // Glass style
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFocused ? const Color(0xFFFF6A00) : Colors.white.withOpacity(0.06), // Accent or subtle glass
          width: isFocused ? 2.0 : 1.0,
        ),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: const Color(0xFFFF6A00).withValues(alpha: 0.2),
                  blurRadius: 10,
                  spreadRadius: 1,
                )
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12), // Reduced from 16
            child: Row(
              children: [
                Container(
                  width: 42, // Reduced from 50
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Color(0xFFFF6A00),
                    size: 24, // Reduced from 32
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15, // Reduced from 17
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        maxLines: 1, // Reduced from 2 for compactness
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 11, // Reduced from 13
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.remove_red_eye_rounded,
                            size: 10,
                            color: Colors.white.withOpacity(0.35),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            views,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.35),
                              fontSize: 10, // Reduced from 12
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
