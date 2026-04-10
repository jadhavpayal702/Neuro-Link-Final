import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:neuro_link/deaf_mode/controllers/play_controller.dart';
import 'package:neuro_link/deaf_mode/controllers/deaf_ui_controller.dart';
import 'package:neuro_link/deaf_mode/services/firestore_service.dart';
import 'package:neuro_link/deaf_mode/services/game_service.dart';
import 'package:neuro_link/deaf_mode/widgets/deaf_theme.dart';
import 'package:neuro_link/deaf_mode/widgets/count_up_text.dart';
import 'package:neuro_link/deaf_mode/widgets/achievement_dialog.dart';
import 'package:neuro_link/deaf_mode/games/memory_game.dart';
import 'package:neuro_link/deaf_mode/games/sign_match_game.dart';
import 'package:neuro_link/deaf_mode/games/pattern_puzzle_game.dart';
import 'package:neuro_link/deaf_mode/games/color_match_game.dart';
import 'package:neuro_link/deaf_mode/games/shape_shifter_game.dart';
import 'package:neuro_link/deaf_mode/games/word_builder_game.dart';
import 'package:neuro_link/deaf_mode/models/game_result_model.dart';

class PlayScreen extends StatefulWidget {
  const PlayScreen({super.key});

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  late PlayController _playController;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? "demo_user_123";
    _playController = PlayController(FirestoreService(), GameService(), uid);
    _playController.initialize();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _launchGame(BuildContext context, String title) {
    Widget gameWidget;
    String gameId;

    switch (title.toLowerCase()) {
      case 'memory match':
        gameId = 'memory';
        gameWidget = MemoryGame(onComplete: (res) => _handleGameComplete(context, res, gameId));
        break;
      case 'sign match':
        gameId = 'sign_match';
        gameWidget = SignMatchGame(onComplete: (res) => _handleGameComplete(context, res, gameId));
        break;
      case 'pattern puzzle':
        gameId = 'pattern';
        gameWidget = PatternPuzzleGame(onComplete: (res) => _handleGameComplete(context, res, gameId));
        break;
      case 'color match':
        gameId = 'color';
        gameWidget = ColorMatchGame(onComplete: (res) => _handleGameComplete(context, res, gameId));
        break;
      case 'shape shifter':
        gameId = 'shape';
        gameWidget = ShapeShifterGame(onComplete: (res) => _handleGameComplete(context, res, gameId));
        break;
      case 'word builder':
        gameId = 'word';
        gameWidget = WordBuilderGame(onComplete: (res) => _handleGameComplete(context, res, gameId));
        break;
      default:
        return;
    }

    Navigator.of(context).push(MaterialPageRoute(builder: (_) => gameWidget));
  }

  void _handleGameComplete(BuildContext context, GameResult result, String gameId) async {
    Navigator.of(context).pop(); // Exit game
    
    final newAchievements = await _playController.updateProgress(result, gameId);
    
    if (mounted) {
      _confettiController.play();
      _showResultDialog(context, result);
      
      // Show achievements sequentially
      for (final ach in newAchievements) {
        await showDialog(
          context: context, 
          builder: (context) => AchievementDialog(achievement: ach)
        );
      }
    }
  }

  void _showResultDialog(BuildContext context, GameResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('🎉 Game Complete!', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Score: ${result.score}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Accuracy: ${(result.accuracy * 100).toInt()}%'),
            const SizedBox(height: 8),
            Text('Time: ${result.timeTaken}s'),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Great!', style: TextStyle(fontSize: 18, color: DeafTheme.orangeA)),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uiController = context.watch<DeafUiController>();
    
    return ChangeNotifierProvider.value(
      value: _playController,
      child: Consumer<PlayController>(
        builder: (context, controller, child) {
          if (controller.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = controller.user;

          return Stack(
            alignment: Alignment.topCenter,
            children: [
              ListView(
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
                          'Your Progress',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Keep growing to learn more......',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _Box(
                                widget: CounterText(
                                  value: user?.points ?? 0, 
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)
                                ), 
                                l: 'Total Points'
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _Box(v: '${user?.gamesPlayed ?? 0}', l: 'Games'),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _Box(v: '${user?.achievements.length ?? 0}', l: 'Achievements'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Available Games',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: uiController.games.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.78,
                    ),
                    itemBuilder: (_, i) {
                      final g = uiController.games[i];
                      return GestureDetector(
                        onTap: () => _launchGame(context, g.title),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(13),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade100,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      g.emoji,
                                      style: const TextStyle(fontSize: 60),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                g.title,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                              ),
                              Text(
                                g.subtitle,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade100,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(7),
                                      child: Text(
                                        g.level,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '☆ ${g.points}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Color.fromARGB(255, 215, 97, 6),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({this.v, this.widget, required this.l});
  final String? v;
  final Widget? widget;
  final String l;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          if (widget != null) widget!
          else if (v != null)
            Text(
              v!,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          Text(l, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
