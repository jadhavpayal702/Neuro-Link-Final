import 'package:flutter/material.dart';
import '../models/message_model.dart';
import 'deaf_theme.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final Function(String emoji)? onReaction;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.onReaction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onLongPress: () => _showReactionMenu(context),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            padding: const EdgeInsets.all(12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            decoration: BoxDecoration(
              color: isMe ? DeafTheme.orangeA : const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 0),
                bottomRight: Radius.circular(isMe ? 0 : 16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.text.isNotEmpty)
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (message.reactions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Wrap(
              spacing: 4,
              children: message.reactions.entries.map((entry) {
                return Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                      )
                    ],
                  ),
                  child: Text(entry.value, style: const TextStyle(fontSize: 12)),
                );
              }).toList(),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          child: Text(
            _formatTime(message.timestamp),
            style: TextStyle(color: Colors.grey[500], fontSize: 10),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime? timestamp) {
    if (timestamp == null) return '';
    final h = timestamp.hour % 12 == 0 ? 12 : timestamp.hour % 12;
    final m = timestamp.minute.toString().padLeft(2, '0');
    final p = timestamp.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $p';
  }

  void _showReactionMenu(BuildContext context) {
    const emojis = ['👍', '❤️', '😊', '🎉', '👋', '🤟', '💯'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: emojis.map((e) => GestureDetector(
            onTap: () {
              onReaction?.call(e);
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(e, style: const TextStyle(fontSize: 24)),
            ),
          )).toList(),
        ),
      ),
    );
  }
}
