import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/route_constants.dart';
import '../../features/foundation/presentation/screens/foundation_screen.dart';

/// Global application navigation configuration utilizing GoRouter.
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'rootNav');

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RouteConstants.root,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: RouteConstants.root,
        name: 'home',
        builder: (context, state) => const FoundationScreen(),
      ),
      GoRoute(
        path: RouteConstants.foundation,
        name: 'foundation',
        builder: (context, state) => const FoundationScreen(),
      ),
      // Placeholder routes for subsequent feature branches
      GoRoute(
        path: RouteConstants.login,
        name: 'login',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Login Feature (Upcoming in v0.3.0)')),
        ),
      ),
      GoRoute(
        path: RouteConstants.dashboard,
        name: 'dashboard',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Instructor/Student Dashboard (Upcoming)')),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 64, color: Colors.redAccent),
              const SizedBox(height: 16),
              const Text(
                '404 - Page Not Found',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'The path ${state.uri.path} does not exist.',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.go(RouteConstants.root),
                icon: const Icon(Icons.home_rounded),
                label: const Text('Return to Home'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
