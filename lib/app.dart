import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/onboarding/screens/profile_setup_screen.dart';
import 'features/discovery/screens/discovery_screen.dart';
import 'features/pairing/screens/qr_show_screen.dart';
import 'features/pairing/screens/qr_scan_screen.dart';
import 'features/permissions/screens/permissions_screen.dart';
import 'features/transfer/screens/send_screen.dart';
import 'features/transfer/screens/receive_screen.dart';
import 'features/chat/screens/chat_screen.dart';
import 'features/live_folder/screens/live_folder_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'features/settings/providers/settings_provider.dart';
import 'shared/widgets/blink_navigation.dart';

/// Route path constants — single source of truth.
abstract class AppRoutes {
  static const onboarding = '/onboarding';
  static const permissions = '/permissions';
  static const profileSetup = '/profile-setup';
  static const discovery = '/';
  static const transfers = '/transfers';
  static const chat = '/chat';
  static const liveFolder = '/live-folder';
  static const settings = '/settings';
  // Sub-routes
  static const qrShow = '/qr/show';
  static const qrScan = '/qr/scan';
  static const send = '/transfer/send';
  static const receive = '/transfer/receive';
}

/// Navigation items for bottom nav and sidebar.
final blinkNavItems = [
  const BlinkNavItem(
    label: 'Discover',
    iconPath: 'assets/svg/nav/radar.svg',
    activeIconPath: 'assets/svg/nav/radar_filled.svg',
    route: AppRoutes.discovery,
  ),
  const BlinkNavItem(
    label: 'Transfers',
    iconPath: 'assets/svg/nav/transfer.svg',
    route: AppRoutes.transfers,
  ),
  const BlinkNavItem(
    label: 'Chat',
    iconPath: 'assets/svg/nav/chat.svg',
    activeIconPath: 'assets/svg/nav/chat_filled.svg',
    route: AppRoutes.chat,
  ),
  const BlinkNavItem(
    label: 'Folders',
    iconPath: 'assets/svg/nav/folder_sync.svg',
    route: AppRoutes.liveFolder,
  ),
  const BlinkNavItem(
    label: 'Settings',
    iconPath: 'assets/svg/nav/settings.svg',
    route: AppRoutes.settings,
  ),
];

/// Main app shell with adaptive navigation.
class _MainShell extends StatelessWidget {
  const _MainShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final currentIndex = _getIndexFromLocation(location);

    return BlinkAdaptiveShell(
      items: blinkNavItems,
      currentIndex: currentIndex,
      onNavigate: (index) {
        context.go(blinkNavItems[index].route);
      },
      child: child,
    );
  }

  int _getIndexFromLocation(String location) {
    for (var i = 0; i < blinkNavItems.length; i++) {
      if (location == blinkNavItems[i].route) return i;
    }
    return 0;
  }
}

final _routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.discovery,
    redirect: (context, state) {
      final settingsAsync = ref.read(settingsNotifierProvider);
      final settings = settingsAsync.value;
      if (settings == null) return null;

      final isOnboarding = state.uri.path == AppRoutes.onboarding;
      final isPermissions = state.uri.path == AppRoutes.permissions;
      final isProfileSetup = state.uri.path == AppRoutes.profileSetup;
      if (!settings.permissionsGranted && !isOnboarding) {
        return AppRoutes.onboarding;
      }
      if (settings.permissionsGranted && !settings.onboarded && !isProfileSetup) {
        return AppRoutes.profileSetup;
      }
      if (settings.onboarded && (isOnboarding || isProfileSetup || isPermissions)) {
        return AppRoutes.discovery;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileSetup,
        builder: (_, __) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: AppRoutes.permissions,
        builder: (_, __) => const PermissionsScreen(),
      ),

      ShellRoute(
        builder: (context, state, child) => _MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.discovery,
            pageBuilder: (_, __) => const NoTransitionPage(
              child: DiscoveryScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.transfers,
            pageBuilder: (_, __) => const NoTransitionPage(
              child: SendScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.chat,
            pageBuilder: (_, __) => const NoTransitionPage(
              child: ChatScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.liveFolder,
            pageBuilder: (_, __) => const NoTransitionPage(
              child: LiveFolderScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (_, __) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
        ],
      ),

      GoRoute(
        path: AppRoutes.qrShow,
        builder: (_, __) => const QrShowScreen(),
      ),
      GoRoute(
        path: AppRoutes.qrScan,
        builder: (_, __) => const QrScanScreen(),
      ),
      GoRoute(
        path: AppRoutes.send,
        builder: (_, __) => const SendScreen(),
      ),
      GoRoute(
        path: AppRoutes.receive,
        builder: (_, __) => const ReceiveScreen(),
      ),
    ],
  );
});

/// Root application widget.
class BlinkApp extends ConsumerWidget {
  const BlinkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsNotifierProvider);
    final router = ref.watch(_routerProvider);

    if (settingsAsync is AsyncLoading && !settingsAsync.hasValue) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: BlinkTheme.dark(),
        home: const Scaffold(
          backgroundColor: Color(0xFF0D0D12),
          body: Center(
            child: CircularProgressIndicator(
              color: Color(0xFF6C63FF),
            ),
          ),
        ),
      );
    }

    return MaterialApp.router(
      title: 'Blink',
      debugShowCheckedModeBanner: false,
      theme: BlinkTheme.light(),
      darkTheme: BlinkTheme.dark(),
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}
