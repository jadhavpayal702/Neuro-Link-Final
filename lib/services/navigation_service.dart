import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'voice_log.dart';

class NavigationService {
  Future<Position> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      throw Exception('Location permission is required for navigation.');
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  Future<List<String>> buildVoiceGuidance({
    required String destinationLabel,
  }) async {
    final position = await getCurrentPosition();
    try {
      // Demo route to a nearby offset so the app returns spoken turn-by-turn text.
      final destLat = position.latitude + 0.0018;
      final destLng = position.longitude + 0.0018;
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/walking/'
        '${position.longitude},${position.latitude};$destLng,$destLat'
        '?steps=true&overview=false',
      );
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final routes = data['routes'] as List<dynamic>? ?? [];
        if (routes.isNotEmpty) {
          final legs = (routes.first as Map<String, dynamic>)['legs'] as List<dynamic>? ?? [];
          final steps = <String>[];
          for (final leg in legs) {
            final legMap = leg as Map<String, dynamic>;
            final legSteps = legMap['steps'] as List<dynamic>? ?? [];
            for (final step in legSteps.take(6)) {
              final stepMap = step as Map<String, dynamic>;
              final maneuver = stepMap['maneuver'] as Map<String, dynamic>? ?? {};
              final modifier = (maneuver['modifier'] ?? 'straight').toString();
              final distance = ((stepMap['distance'] ?? 20) as num).round();
              steps.add('Go $modifier for $distance meters.');
            }
          }
          if (steps.isNotEmpty) {
            return [
              'Starting navigation to $destinationLabel.',
              ...steps,
              'You are nearing your destination.',
            ];
          }
        }
      }
    } catch (_) {}

    return [
      'Starting navigation to $destinationLabel.',
      'Walk straight for 50 meters.',
      'Turn left and continue for 80 meters.',
      'Destination is near your right side.',
    ];
  }
}

/// Global voice-triggered navigation for Vocal Mode (named routes on [navigatorKey]).
class VoiceNavigationService {
  VoiceNavigationService();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static const String vocalHome = '/vocal';
  static const String learn = '/vocal/learn';
  static const String communicate = '/vocal/communicate';
  static const String play = '/vocal/play';
  static const String control = '/vocal/control';
  static const String community = '/vocal/community';
  static const String navigation = '/vocal/navigation';

  NavigatorState? get _nav => navigatorKey.currentState;

  void pushLearn() {
    _pushNamed(learn, 'learn');
  }

  void pushCommunicate() {
    _pushNamed(communicate, 'communicate');
  }

  void pushPlay() {
    _pushNamed(play, 'play');
  }

  void pushControl() {
    _pushNamed(control, 'control');
  }

  void pushCommunity() {
    _pushNamed(community, 'community');
  }

  void pushNavigation() {
    _pushNamed(navigation, 'navigation');
  }

  void _pushNamed(String route, String label) {
    final nav = _nav;
    if (nav == null) {
      VoiceLog.navigation('navigator null, skip $label', detail: route);
      return;
    }
    VoiceLog.navigation('pushNamed', detail: route);
    nav.pushNamed(route);
  }

  /// Pops one route if possible (voice "back").
  void pop() {
    final nav = _nav;
    if (nav == null) return;
    if (nav.canPop()) {
      VoiceLog.navigation('pop', detail: null);
      nav.pop();
    }
  }

  /// Pops until Vocal home dashboard.
  void popToVocalHome() {
    final nav = _nav;
    if (nav == null) return;
    VoiceLog.navigation('popToVocalHome', detail: vocalHome);
    nav.popUntil((route) {
      final name = route.settings.name;
      return name == vocalHome || route.isFirst;
    });
  }

  /// Pops to app mode picker (root).
  void popToAppRoot() {
    final nav = _nav;
    if (nav == null) return;
    VoiceLog.navigation('popToAppRoot', detail: '/');
    nav.popUntil((route) => route.isFirst);
  }
}
