import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/server_select/screens/server_select_screen.dart';
import 'shared/widgets/app_title_bar.dart';
import 'features/character_select/screens/character_select_screen.dart';
import 'features/task_detail/screens/task_detail_screen.dart';
import 'core/theme/app_theme.dart';

class MobiHelperApp extends StatelessWidget {
  const MobiHelperApp({super.key});

  static final GoRouter _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
          return const AppShell(child: DashboardScreen());
        },
      ),
      GoRoute(
        path: '/servers',
        builder: (context, state) {
          return const AppShell(child: ServerSelectScreen());
        },
      ),
      GoRoute(
        path: '/servers/:serverId/characters',
        builder: (context, state) {
          final serverId = state.pathParameters['serverId'] ?? '';

          return AppShell(child: CharacterSelectScreen(serverId: serverId));
        },
      ),
      GoRoute(
        path: '/characters/:characterId/tasks',
        builder: (context, state) {
          final characterId = state.pathParameters['characterId'] ?? '';

          return AppShell(child: TaskDetailScreen(characterId: characterId));
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Mobi Helper',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: _router,
    );
  }
}

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const AppTitleBar(),
          Expanded(child: child),
        ],
      ),
    );
  }
}
