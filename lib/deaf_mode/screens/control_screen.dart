import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/deaf_ui_controller.dart';
import '../widgets/deaf_theme.dart';

class ControlScreen extends StatelessWidget {
  const ControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<DeafUiController>();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: DeafTheme.topGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(16),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Smart Home',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              Text(
                'Control your devices visually',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFF3B2B2), width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '❗ Emergency Panel',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _Emergency(
                      label: 'Alert',
                      emoji: '🚨',
                      color: Color(0xFFFF2D3B),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _Emergency(
                      label: 'Police',
                      emoji: '👮',
                      color: Color(0xFF3B82F6),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _Emergency(
                      label: 'Medical',
                      emoji: '🏥',
                      color: Color(0xFF22C55E),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'All Devices',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        const SizedBox(height: 8),
        ...c.devices.asMap().entries.map((entry) {
          final i = entry.key;
          final d = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: d.on ? DeafTheme.orangeA : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: DeafTheme.orangeA,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Text(d.icon, style: const TextStyle(fontSize: 26)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(d.room),
                      Text(d.on ? '● ON' : '○ OFF'),
                    ],
                  ),
                ),
                Switch(
                  activeColor: DeafTheme.orangeA,
                  inactiveThumbColor: Colors.grey.shade300,
                  inactiveTrackColor: Colors.grey.shade300,

                  value: d.on,
                  onChanged: (v) =>
                      context.read<DeafUiController>().toggleDevice(i, v),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _Emergency extends StatelessWidget {
  const _Emergency({
    required this.label,
    required this.emoji,
    required this.color,
  });
  final String label;
  final String emoji;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          '$emoji $label',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
