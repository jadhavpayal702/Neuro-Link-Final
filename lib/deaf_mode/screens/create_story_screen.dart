import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/community_models.dart';
import '../services/community_service.dart';
import '../widgets/deaf_theme.dart';

class CreateStoryScreen extends StatefulWidget {
  final UserModel user;
  const CreateStoryScreen({super.key, required this.user});

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  final TextEditingController _textController = TextEditingController();
  Color _bgColor = DeafTheme.orangeA;
  String _fontStyle = 'normal';
  double _fontSize = 28;

  final List<Color> _colors = [
    DeafTheme.orangeA,
    Colors.purple,
    Colors.blue,
    Colors.green,
    Colors.pink,
    Colors.black,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const CloseButton(color: Colors.white),
        actions: [
          TextButton(
            onPressed: _postStory,
            child: const Text('Post', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: TextField(
            controller: _textController,
            maxLines: null,
            textAlign: TextAlign.center,
            autofocus: true,
            cursorColor: Colors.white,
            style: TextStyle(
              color: Colors.white,
              fontSize: _fontSize,
              fontWeight: _fontStyle == 'bold' ? FontWeight.bold : FontWeight.normal,
              fontStyle: _fontStyle == 'italic' ? FontStyle.italic : FontStyle.normal,
            ),
            decoration: const InputDecoration(
              hintText: 'Type something...',
              hintStyle: TextStyle(color: Colors.white60),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.black26,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _toolIcon(Icons.format_size, () => setState(() => _fontSize = _fontSize == 28 ? 40 : 28)),
                _toolIcon(Icons.format_bold, () => setState(() => _fontStyle = _fontStyle == 'bold' ? 'normal' : 'bold')),
                _toolIcon(Icons.format_italic, () => setState(() => _fontStyle = _fontStyle == 'italic' ? 'normal' : 'italic')),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _colors.map((c) => GestureDetector(
                  onTap: () => setState(() => _bgColor = c),
                  child: Container(
                    width: 40,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: _bgColor == c ? 3 : 1),
                    ),
                  ),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toolIcon(IconData icon, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, color: Colors.white),
      onPressed: onTap,
    );
  }

  void _postStory() async {
    if (_textController.text.isEmpty) return;

    final story = StoryModel(
      id: '',
      userId: widget.user.uid,
      userName: widget.user.name,
      userEmoji: widget.user.profileEmoji,
      storyData: StoryData(
        text: _textController.text,
        backgroundColor: '#${_bgColor.toValue().toRadixString(16).padLeft(8, '0').substring(2)}',
        fontSize: _fontSize,
        fontStyle: _fontStyle,
      ),
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
    );

    await CommunityService().createStory(story);
    if (mounted) Navigator.pop(context);
  }
}

extension ColorExtension on Color {
  int toValue() => (a.clamp(0.0, 1.0) * 255).toInt() << 24 |
                   (r.clamp(0.0, 1.0) * 255).toInt() << 16 |
                   (g.clamp(0.0, 1.0) * 255).toInt() << 8 |
                   (b.clamp(0.0, 1.0) * 255).toInt();
}
