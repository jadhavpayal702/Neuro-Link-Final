import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/deaf_ui_controller.dart';
import 'screens/community_screen.dart';
import 'screens/communicate_screen.dart';
import 'screens/control_screen.dart';
import 'screens/learn_screen.dart';
import 'screens/play_screen.dart';
import 'screens/profile_screen.dart';
import 'models/user_model.dart';
import 'screens/ai_chat_screen.dart';
import 'screens/user_discovery_screen.dart';
import 'services/deaf_ui_data_service.dart';
import 'services/firestore_service.dart';
import 'widgets/deaf_scaffold.dart';
import 'widgets/deaf_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DeafModeHome extends StatefulWidget {
  const DeafModeHome({super.key});

  @override
  State<DeafModeHome> createState() => _DeafModeHomeState();
}

class _DeafModeHomeState extends State<DeafModeHome> {
  int index = 0;
  late final DeafUiController controller;
  final String _currentUid = FirebaseAuth.instance.currentUser?.uid ?? "demo_user_123";

  @override
  void initState() {
    super.initState();
    controller = DeafUiController(DeafUiDataService())..initialize();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const LearnScreen(),
      const CommunicateScreen(),
      const PlayScreen(),
      const ControlScreen(),
      const CommunityScreen(),
    ];
    final titles = [
      'Deaf Mode',
      'Communicate',
      'Games',
      'Smart Control',
      'Community',
    ];
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: controller),
        Provider<String>.value(value: _currentUid),
      ],
      child: Builder(
        builder: (context) {
          final c = context.watch<DeafUiController>();
          if (c.loading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return StreamBuilder<UserModel?>(
            stream: FirestoreService().streamUserProfile(_currentUid),
            builder: (context, snapshot) {
              final user = snapshot.data;
              final bool isComplete = user?.profileCompleted ?? false;

              return Stack(
                children: [
                  DeafScaffold(
                    title: titles[index],
                    index: index,
                    onTab: (i) => setState(() => index = i),
                    onProfileTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ProfileScreen(
                          uid: _currentUid,
                          existingUser: user,
                        ),
                      ),
                    ),
                    child: pages[index],
                  ),
                  if (!isComplete && (index == 1))
                    _buildProfileBarrier(context, user),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProfileBarrier(BuildContext context, UserModel? user) {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_person, size: 64, color: DeafTheme.orangeA),
              const SizedBox(height: 24),
              const Text(
                "Profile Incomplete",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                "You must complete your profile before accessing communication features.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ProfileScreen(
                          uid: _currentUid,
                          existingUser: user,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DeafTheme.orangeA,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    "Complete Profile",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
