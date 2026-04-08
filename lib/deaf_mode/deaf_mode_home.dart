import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/deaf_ui_controller.dart';
import 'screens/community_screen.dart';
import 'screens/communicate_screen.dart';
import 'screens/control_screen.dart';
import 'screens/learn_screen.dart';
import 'screens/play_screen.dart';
import 'screens/profile_screen.dart';
import 'services/deaf_ui_data_service.dart';
import 'widgets/deaf_scaffold.dart';

class DeafModeHome extends StatefulWidget {
  const DeafModeHome({super.key});

  @override
  State<DeafModeHome> createState() => _DeafModeHomeState();
}

class _DeafModeHomeState extends State<DeafModeHome> {
  int index = 0;
  late final DeafUiController controller;

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
    return ChangeNotifierProvider.value(
      value: controller,
      child: Builder(
        builder: (context) {
          final c = context.watch<DeafUiController>();
          if (c.loading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return DeafScaffold(
            title: titles[index],
            index: index,
            onTab: (i) => setState(() => index = i),
            onProfileTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
            ),
            child: pages[index],
          );
        },
      ),
    );
  }
}
