import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/equipment_selection_screen.dart';
import 'screens/troubleshooting_screen.dart';
import 'screens/chat_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: FixBotApp()));
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
    GoRoute(
      path: '/equipment',
      builder: (_, __) => const EquipmentSelectionScreen(),
    ),
    GoRoute(
      path: '/troubleshooting',
      builder: (context, state) {
        final extra = state.extra as Map<String, String>?;
        return TroubleshootingScreen(
          equipment: extra?['equipment'] ?? 'Motor',
          brand: extra?['brand'] ?? 'Siemens',
          model: extra?['model'] ?? '1LA7 Motor',
        );
      },
    ),
    GoRoute(
      path: '/chat',
      builder: (context, state) {
        final extra = state.extra as Map<String, String>?;
        return ChatScreen(
          equipment: extra?['equipment'] ?? 'Motor',
          brand: extra?['brand'] ?? 'Siemens',
          model: extra?['model'] ?? '1LA7 Motor',
          problem: extra?['problem'] ?? '',
        );
      },
    ),
  ],
);

class FixBotApp extends StatelessWidget {
  const FixBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FixBot',
      theme: AppTheme.lightTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

