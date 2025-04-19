import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gunwave/views/home/home_view.dart';
import 'package:gunwave/views/splash/splash_view.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class Routes {

  static const splash = '/splash';
  static const home = '/home';

  static final GoRouter config = GoRouter(
    initialLocation: splash,
    debugLogDiagnostics: false,
    navigatorKey: navigatorKey,
    routes: [
      _buildSplashRoute(),
      _buildHomeRoute(),
    ],
  );
  
  static GoRoute _buildSplashRoute() {
    return GoRoute(
      path: splash,
      name: splash,
      pageBuilder: (context, state) => const NoTransitionPage(child: SplashView()),
    );
  }

  static GoRoute _buildHomeRoute() {
    return GoRoute(
      path: home,
      name: home,
      pageBuilder: (context, state) => const NoTransitionPage(child: HomeView()),
    );
  }
}
