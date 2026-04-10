import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/video.dart';
import '../widgets/eye_video_card.dart';

typedef FocusableBuilder = Widget Function({required int index, required Widget child});

class LearnVideoPage extends StatelessWidget {
  final String title;
  final List<Video> videos;
  final FocusableBuilder focusableBuilder;
  final int focusStartIndex;
  final int focusIndex;
  final VoidCallback onBack;

  const LearnVideoPage({
    super.key,
    required this.title,
    required this.videos,
    required this.focusableBuilder,
    required this.focusStartIndex,
    required this.focusIndex,
    required this.onBack,
  });

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              return focusableBuilder(
                index: focusStartIndex + index,
                child: EyeVideoCard(
                  title: video.title,
                  description: video.description,
                  views: video.views,
                  isFocused: focusIndex == (focusStartIndex + index),
                  onTap: () => _launchUrl(video.url),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
