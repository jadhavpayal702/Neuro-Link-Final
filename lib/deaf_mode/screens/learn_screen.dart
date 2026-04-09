import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/deaf_ui_controller.dart';
import '../widgets/deaf_theme.dart';
import '../widgets/quick_actions.dart';
import 'lesson_screen.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Keep Learning! 📚',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${c.courses.length} active courses',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: c.courses.isEmpty
                      ? 0
                      : c.courses
                                .map((e) => e.progress)
                                .reduce((a, b) => a + b) /
                            c.courses.length,
                  minHeight: 10,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    const Color.fromARGB(234, 255, 170, 0),
                  ),
                  backgroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'My Courses',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        const SizedBox(height: 10),
        ...c.courses.map(
          (course) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.deepOrange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    course.icon,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      Text('${course.lessons} lessons'),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: course.progress,
                        minHeight: 7,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          const Color.fromARGB(234, 255, 102, 0),
                        ),
                        backgroundColor: Colors.white,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 40,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => LessonScreen(title: course.title),
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: DeafTheme.topGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // const SizedBox(height: 8),
        // const Text(
        //   'Captioned Videos',
        //   style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        // ),
        // const SizedBox(height: 8),
        // ...c.videos.map(
        //   (video) => Container(
        //     margin: const EdgeInsets.only(bottom: 10),
        //     padding: const EdgeInsets.all(12),
        //     decoration: BoxDecoration(
        //       color: Colors.white,
        //       borderRadius: BorderRadius.circular(16),
        //     ),
        //     child: Row(
        //       children: [
        //         Container(
        //           width: 62,
        //           height: 62,
        //           decoration: BoxDecoration(
        //             color: DeafTheme.orangeA,
        //             borderRadius: BorderRadius.circular(12),
        //           ),
        //           alignment: Alignment.center,
        //           child: Text(
        //             video.thumbnail,
        //             style: const TextStyle(fontSize: 28),
        //           ),
        //         ),
        //         const SizedBox(width: 10),
        //         Expanded(
        //           child: Column(
        //             crossAxisAlignment: CrossAxisAlignment.start,
        //             children: [
        //               Text(
        //                 video.title,
        //                 style: const TextStyle(fontWeight: FontWeight.w700),
        //               ),
        //               Text('Duration: ${video.duration}'),
        //               if (video.captions) const Text('CC   🤟 Sign'),
        //             ],
        //           ),
        //         ),
        //         const Icon(Icons.play_arrow_rounded, color: DeafTheme.orangeA),
        //       ],
        //     ),
        //   ),
        // ),
        //const SizedBox(height: 10),
        const QuickActions(),
      ],
    );
  }
}
