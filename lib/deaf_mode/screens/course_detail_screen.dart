  import 'package:flutter/material.dart';
import '../models/learn_models.dart';
import '../widgets/deaf_theme.dart';
import '../widgets/learn_widgets.dart';
import 'quiz_screen.dart';

class CourseDetailScreen extends StatelessWidget {
  final CourseDetailModel course;
  const CourseDetailScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: DeafTheme.bg,
        appBar: AppBar(
          title: Text(course.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: DeafTheme.orangeA,
            labelColor: DeafTheme.orangeA,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Videos'),
              Tab(text: 'Quizzes'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildVideosTab(),
            _buildQuizzesTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildVideosTab() {
    final List<Widget> items = [];
    
    if (course.books != null && course.books!.isNotEmpty) {
      items.add(const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text('Reading Materials', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ));
      items.addAll(course.books!.map((b) => BookCard(book: b)).toList());
    }

    if (course.videos.isNotEmpty) {
      items.add(const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text('Video Lessons', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ));
      items.addAll(course.videos.map((v) => VideoCard(video: v)).toList());
    }

    if (items.isEmpty) {
      return const Center(child: Text('No content available yet.'));
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: items,
    );
  }

  Widget _buildQuizzesTab(BuildContext context) {
    if (course.quizzes.isEmpty) {
      return const Center(child: Text('No quizzes available yet.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: course.quizzes.length,
      itemBuilder: (context, index) {
        final quiz = course.quizzes[index];
        return QuizCard(
          quiz: quiz,
          onStart: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => QuizScreen(quiz: quiz)),
            );
          },
        );
      },
    );
  }
}
