import 'dart:async';
import 'package:flutter/material.dart';
import '../models/community_models.dart';
import '../widgets/deaf_theme.dart';

class StoryViewerScreen extends StatefulWidget {
  final List<StoryModel> stories;
  final int initialIndex;

  const StoryViewerScreen({
    super.key,
    required this.stories,
    required this.initialIndex,
  });

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _animController = AnimationController(vsync: this);

    _loadStory(story: widget.stories[_currentIndex]);

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animController.stop();
        _animController.reset();
        setState(() {
          if (_currentIndex + 1 < widget.stories.length) {
            _currentIndex++;
            _loadStory(story: widget.stories[_currentIndex]);
            _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
          } else {
            Navigator.pop(context);
          }
        });
      }
    });
  }

  void _loadStory({required StoryModel story, bool animateToPage = true}) {
    _animController.stop();
    _animController.reset();
    _animController.duration = const Duration(seconds: 5);
    _animController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.stories[_currentIndex];
    final color = Color(int.parse(story.storyData.backgroundColor.replaceAll('#', '0xFF')));

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) {
          final screenWidth = MediaQuery.of(context).size.width;
          final dx = details.globalPosition.dx;
          if (dx < screenWidth / 3) {
            if (_currentIndex > 0) {
              setState(() {
                _currentIndex--;
                _loadStory(story: widget.stories[_currentIndex]);
                _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
              });
            }
          } else if (dx > 2 * screenWidth / 3) {
            if (_currentIndex + 1 < widget.stories.length) {
              setState(() {
                _currentIndex++;
                _loadStory(story: widget.stories[_currentIndex]);
                _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
              });
            } else {
              Navigator.pop(context);
            }
          }
        },
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.stories.length,
              itemBuilder: (context, i) {
                final s = widget.stories[i];
                final bgColor = Color(int.parse(s.storyData.backgroundColor.replaceAll('#', '0xFF')));
                return Container(
                  color: bgColor,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Text(
                        s.storyData.text,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: s.storyData.fontSize,
                          fontWeight: s.storyData.fontStyle == 'bold' ? FontWeight.bold : FontWeight.normal,
                          fontStyle: s.storyData.fontStyle == 'italic' ? FontStyle.italic : FontStyle.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 40,
              left: 10,
              right: 10,
              child: Column(
                children: [
                  Row(
                    children: widget.stories.asMap().entries.map((it) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: LinearProgressIndicator(
                            value: it.key == _currentIndex ? _animController.value : (it.key < _currentIndex ? 1 : 0),
                            backgroundColor: Colors.white38,
                            valueColor: const AlwaysStoppedAnimation(Colors.white),
                            minHeight: 2,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white24, border: Border.all(color: Colors.white, width: 1)),
                        alignment: Alignment.center,
                        child: Text(story.userEmoji, style: const TextStyle(fontSize: 24)),
                      ),
                      const SizedBox(width: 10),
                      Text(story.userName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      const Spacer(),
                      IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
