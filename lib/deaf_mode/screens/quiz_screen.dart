import 'package:flutter/material.dart';
import '../models/learn_models.dart';
import '../widgets/deaf_theme.dart';
import '../widgets/learn_widgets.dart';

class QuizScreen extends StatefulWidget {
  final QuizModel quiz;
  const QuizScreen({super.key, required this.quiz});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int? _selectedIndex;
  int _score = 0;
  bool _showFeedback = false;
  bool _isFinished = false;

  void _handleAnswer(int index) {
    if (_showFeedback) return;
    setState(() {
      _selectedIndex = index;
      _showFeedback = true;
      if (index == widget.quiz.questions[_currentIndex].correctIndex) {
        _score++;
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      if (_currentIndex < widget.quiz.questions.length - 1) {
        setState(() {
          _currentIndex++;
          _selectedIndex = null;
          _showFeedback = false;
        });
      } else {
        setState(() {
          _isFinished = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isFinished) return _buildResult();

    final currentQuestion = widget.quiz.questions[_currentIndex];
    final progress = (_currentIndex + 1) / widget.quiz.questions.length;

    return Scaffold(
      backgroundColor: DeafTheme.bg,
      appBar: AppBar(
        title: Text(widget.quiz.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${_currentIndex + 1}/${widget.quiz.questions.length}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('${(progress * 100).toInt()}%'),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.white,
                    valueColor: const AlwaysStoppedAnimation(DeafTheme.orangeA),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: QuestionWidget(
                question: currentQuestion,
                selectedIndex: _selectedIndex,
                onSelect: _handleAnswer,
                showFeedback: _showFeedback,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    return Scaffold(
      backgroundColor: DeafTheme.bg,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '🎉',
                style: TextStyle(fontSize: 80),
              ),
              const SizedBox(height: 20),
              const Text(
                'Quiz Completed!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Text(
                'You scored $_score out of ${widget.quiz.questions.length}',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: DeafTheme.orangeA,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text(
                    'Back to Lessons',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
