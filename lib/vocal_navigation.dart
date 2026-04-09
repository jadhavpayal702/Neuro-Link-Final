import 'package:flutter/material.dart';

import 'services/navigation_service.dart';

/// Pushes the Vocal Mode section that matches [index] (0–4) using named routes.
void pushVocalSection(BuildContext context, int index) {
  final String route = switch (index) {
    0 => VoiceNavigationService.learn,
    1 => VoiceNavigationService.communicate,
    2 => VoiceNavigationService.play,
    3 => VoiceNavigationService.control,
    4 => VoiceNavigationService.community,
    _ => VoiceNavigationService.learn,
  };
  Navigator.of(context).pushNamed(route);
}
