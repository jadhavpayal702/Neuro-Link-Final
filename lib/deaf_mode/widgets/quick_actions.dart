import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/profile_screen.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  Future<void> _makeSosCall() async {
    final Uri url = Uri.parse('tel:100');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch SOS call');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '⚡ Quick Actions',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _Q(
                  icon: '🚨',
                  label: 'Help',
                  onTap: _makeSosCall,
                  color: const Color(0xFFFEF2F2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Q(
                  icon: '📍',
                  label: 'Location',
                  onTap: () {}, // Noop for now
                  color: const Color(0xFFF0FDF4),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Q(
                  icon: '👤',
                  label: 'Profile',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  },
                  color: const Color(0xFFEFF6FF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Q extends StatelessWidget {
  const _Q({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });
  final String icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 78,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
