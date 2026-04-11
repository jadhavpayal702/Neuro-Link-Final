import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'vocal-mode/controllers/neurobot_controller.dart';
import 'vocal-mode/controllers/vocal_controller.dart';
import 'vocal-mode/services/ai_service.dart';
import 'vocal-mode/services/navigation_service.dart';
import 'vocal-mode/services/tts_service.dart';
import 'vocal-mode/services/voice_service.dart';
import 'vocal-mode/screens/community_screen.dart';
import 'vocal-mode/screens/communicate_screen.dart';
import 'vocal-mode/screens/control_screen.dart';
import 'vocal-mode/screens/home_screen.dart';
import 'vocal-mode/screens/learn_screen.dart';
import 'vocal-mode/screens/navigation_screen.dart';
import 'vocal-mode/screens/play_screen.dart';
import 'vocal-mode/screens/vocal_home.dart';
import 'splashScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyCUNoMNfUosoS8KYJYQSvnB1YItNutNtw4",
      appId: "1:488503581921:android:3b8b99035fbbcf0f902ba0",
      messagingSenderId: "488503581921",
      projectId: "neurolink-1a56c",
      storageBucket: "neurolink-1a56c.firebasestorage.app",
    ),
  );
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const NeuroLinkApp());
}

class NeuroLinkApp extends StatelessWidget {
  const NeuroLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<VoiceService>(create: (_) => VoiceService()),
        Provider<TtsService>(create: (_) => TtsService()),
        Provider<AiService>(create: (_) => AiService()),
        Provider<NavigationService>(create: (_) => NavigationService()),
        Provider<VoiceNavigationService>(
          create: (_) => VoiceNavigationService(),
        ),
        ChangeNotifierProvider<NeurobotController>(
          create: (context) => NeurobotController(
            aiService: context.read<AiService>(),
            ttsService: context.read<TtsService>(),
          ),
        ),
        ChangeNotifierProvider<VocalController>(
          create: (context) => VocalController(
            voiceService: context.read<VoiceService>(),
            ttsService: context.read<TtsService>(),
            navigationService: context.read<NavigationService>(),
            neurobotController: context.read<NeurobotController>(),
            voiceNavigation: context.read<VoiceNavigationService>(),
          ),
        ),
      ],
      child: Builder(
        builder: (context) {
          final voiceNav = context.read<VoiceNavigationService>();
          return MaterialApp(
            navigatorKey: voiceNav.navigatorKey,
            title: 'NeuroLink',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF2563EB),
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              scaffoldBackgroundColor: const Color(0xFFF5F7FA),
            ),
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              '/home': (context) => const HomeScreen(),
              VoiceNavigationService.vocalHome: (context) =>
                  const VocalHomeScreen(),
              VoiceNavigationService.learn: (context) => const LearnScreen(),
              VoiceNavigationService.communicate: (context) =>
                  const CommunicateScreen(),
              VoiceNavigationService.play: (context) => const PlayScreen(),
              VoiceNavigationService.control: (context) =>
                  const ControlScreen(),
              VoiceNavigationService.community: (context) =>
                  const CommunityScreen(),
              VoiceNavigationService.navigation: (context) =>
                  const NavigationScreen(),
            },
          );
        },
      ),
    );
  }
}
