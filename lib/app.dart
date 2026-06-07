import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/server_select/screens/server_select_screen.dart';
import 'shared/widgets/app_title_bar.dart';

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
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Mobi Helper',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'AppFont',
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFFAFBFF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00A8FF),
          brightness: Brightness.light,
        ),

        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF00A8FF),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontFamily: 'AppFont',
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF00A8FF),
            textStyle: const TextStyle(
              fontFamily: 'AppFont',
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }

            return const Color(0xFF8B949E);
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFF00A8FF);
            }

            return const Color(0xFFE5E7EB);
          }),
          trackOutlineColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFF00A8FF);
            }

            return const Color(0xFFCBD5E1);
          }),
        ),
      ),
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
