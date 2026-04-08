import 'package:flutter/material.dart';

import 'deaf_theme.dart';

class DeafScaffold extends StatelessWidget {
  const DeafScaffold({
    super.key,
    required this.title,
    required this.child,
    required this.index,
    required this.onTab,
    required this.onProfileTap,
  });

  final String title;
  final Widget child;
  final int index;
  final ValueChanged<int> onTab;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DeafTheme.bg,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(13, 13, 13, 1),
            decoration: const BoxDecoration(gradient: DeafTheme.topGradient),
            child: Row(
              children: [
                _circle(
                  Icons.arrow_back_ios_new_rounded,
                  () => Navigator.of(context).maybePop(),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 36 / 2,
                    ),
                  ),
                ),
                _circle(
                  Icons.home_outlined,
                  () => Navigator.of(context).maybePop(),
                ),
                const SizedBox(width: 8),
                _circle(Icons.person_outline, onProfileTap),
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
      // bottomNavigationBar: NavigationBar(
      //   selectedIndex: index,
      //   onDestinationSelected: onTab,
      //   destinations: const [
      //     NavigationDestination(
      //       icon: Icon(Icons.menu_book_outlined),
      //       label: 'Learn',
      //     ),
      //     NavigationDestination(
      //       icon: Icon(Icons.chat_bubble_outline),
      //       label: 'Communicate',
      //     ),
      //     NavigationDestination(
      //       icon: Icon(Icons.sports_esports_outlined),
      //       label: 'Play',
      //     ),
      //     NavigationDestination(
      //       icon: Icon(Icons.tune_rounded),
      //       label: 'Control',
      //     ),
      //     NavigationDestination(
      //       icon: Icon(Icons.groups_outlined),
      //       label: 'Community',
      //     ),
      //   ],
      // ),
      bottomNavigationBar: NavigationBar(
        height: 70,
        selectedIndex: index,
        onDestinationSelected: onTab,
        backgroundColor: Colors.white,
        elevation: 8,

        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,

        destinations: [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Learn',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Communicate',
          ),
          NavigationDestination(
            icon: Icon(Icons.sports_esports_outlined),
            selectedIcon: Icon(Icons.sports_esports),
            label: 'Play',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_rounded),
            selectedIcon: Icon(Icons.tune),
            label: 'Control',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Community',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color.fromARGB(255, 234, 82, 0),
        child: const Icon(Icons.assistant, color: Colors.white),
      ),
    );
  }

  Widget _circle(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white.withValues(alpha: 0.25),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}
