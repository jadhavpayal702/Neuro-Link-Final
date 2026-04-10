import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/deaf_theme.dart';
import 'ai_chat_screen.dart';
import 'user_discovery_screen.dart';

class CommunicateScreen extends StatefulWidget {
  const CommunicateScreen({super.key});

  @override
  State<CommunicateScreen> createState() => _CommunicateScreenState();
}

class _CommunicateScreenState extends State<CommunicateScreen> {
  bool aiMode = false;

  @override
  Widget build(BuildContext context) {
    final currentUid = Provider.of<String>(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                )
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _tab(
                    '💬 Text Chat',
                    !aiMode,
                    () => setState(() => aiMode = false),
                  ),
                ),
                Expanded(
                  child: _tab(
                    '🤖 AI Assistant',
                    aiMode,
                    () => setState(() => aiMode = true),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: aiMode 
              ? const AiChatScreen() 
              : UserDiscoveryScreen(currentUid: currentUid),
          ),
        ),
      ],
    );
  }

  Widget _tab(String text, bool selected, VoidCallback tap) {
    return Material(
      color: selected ? DeafTheme.orangeA : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: tap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 48,
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
