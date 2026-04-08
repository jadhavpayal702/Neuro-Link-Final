import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/deaf_ui_controller.dart';
import '../widgets/deaf_theme.dart';

class CommunicateScreen extends StatefulWidget {
  const CommunicateScreen({super.key});

  @override
  State<CommunicateScreen> createState() => _CommunicateScreenState();
}

class _CommunicateScreenState extends State<CommunicateScreen> {
  final TextEditingController _input = TextEditingController();
  bool ai = false;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<DeafUiController>();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _tab(
                      '💬 Text Chat',
                      !ai,
                      () => setState(() => ai = false),
                    ),
                  ),
                ),
                Expanded(
                  child: _tab(
                    '🤖 AI Assistant',
                    ai,
                    () => setState(() => ai = true),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              ...c.chat.map(
                (m) => Align(
                  alignment: m.isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(
                      minHeight: 48,
                      maxWidth: 260,
                    ),
                    decoration: BoxDecoration(
                      color: m.isUser
                          ? DeafTheme.orangeA
                          : const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '${m.message}\n${m.time}',
                      style: TextStyle(
                        color: m.isUser ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
              if (!ai)
                const Padding(
                  padding: EdgeInsets.only(top: 6, bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('👍', style: TextStyle(fontSize: 20)),
                      Text('❤️', style: TextStyle(fontSize: 20)),
                      Text('😊', style: TextStyle(fontSize: 20)),
                      Text('🎉', style: TextStyle(fontSize: 20)),
                      Text('👋', style: TextStyle(fontSize: 20)),
                      Text('🤟', style: TextStyle(fontSize: 20)),
                      Text('💯'),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: DeafTheme.orangeA,
                child: Icon(Icons.image_outlined, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _input,
                  decoration: const InputDecoration(
                    hintText: 'Type your message...',
                    hintStyle: TextStyle(
                      color: Color.fromARGB(221, 231, 57, 13),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),

                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(26)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () async {
                  if (_input.text.trim().isEmpty) return;
                  await context.read<DeafUiController>().sendChat(
                    _input.text.trim(),
                  );
                  _input.clear();
                },
                child: const CircleAvatar(
                  radius: 24,
                  backgroundColor: DeafTheme.orangeA,
                  child: Icon(Icons.send, color: Colors.white),
                ),
              ),
            ],
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
