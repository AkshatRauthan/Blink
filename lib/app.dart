import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/discovery/screens/discovery_screen.dart';
import 'features/pairing/screens/qr_show_screen.dart';
import 'features/pairing/screens/qr_scan_screen.dart';
import 'features/transfer/screens/send_screen.dart';
import 'features/transfer/screens/receive_screen.dart';
import 'features/chat/screens/chat_screen.dart';
import 'features/live_folder/screens/live_folder_screen.dart';
import 'features/settings/screens/settings_screen.dart';

/// Route path constants — single source of truth.
abstract class AppRoutes {
  static const onboarding = '/onboarding';
  static const discovery = '/';
  static const qrShow = '/qr/show';
  static const qrScan = '/qr/scan';
  static const send = '/transfer/send';
  static const receive = '/transfer/receive';
  static const chat = '/chat';
  static const liveFolder = '/live-folder';
  static const settings = '/settings';
}

final _router = GoRouter(
  initialLocation: AppRoutes.discovery,
  routes: [
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (_, _) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.discovery,
      builder: (_, _) => const DiscoveryScreen(),
    ),
    GoRoute(
      path: AppRoutes.qrShow,
      builder: (_, _) => const QrShowScreen(),
    ),
    GoRoute(
      path: AppRoutes.qrScan,
      builder: (_, _) => const QrScanScreen(),
    ),
    GoRoute(
      path: AppRoutes.send,
      builder: (_, _) => const SendScreen(),
    ),
    GoRoute(
      path: AppRoutes.receive,
      builder: (_, _) => const ReceiveScreen(),
    ),
    GoRoute(
      path: AppRoutes.chat,
      builder: (_, _) => const ChatScreen(),
    ),
    GoRoute(
      path: AppRoutes.liveFolder,
      builder: (_, _) => const LiveFolderScreen(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (_, _) => const SettingsScreen(),
    ),
  ],
);

/// Root application widget.
class BlinkApp extends StatelessWidget {
  const BlinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Blink',
      debugShowCheckedModeBanner: false,
      theme: BlinkTheme.light(),
      darkTheme: BlinkTheme.dark(),
      routerConfig: _router,
    );
  }
}
