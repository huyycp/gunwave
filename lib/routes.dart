import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gunwave/views/character/character_view.dart';
import 'package:gunwave/views/home/home_view.dart';
import 'package:gunwave/views/map/map_view.dart';
import 'package:gunwave/views/splash/splash_view.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class Routes {

  static const splash = '/splash';
  static const home = '/home';
  static const map = '/map';
  static const character = '/character';

  static final GoRouter config = GoRouter(
    initialLocation: splash,
    debugLogDiagnostics: false,
    navigatorKey: navigatorKey,
    routes: [
      _buildSplashRoute(),
      _buildHomeRoute(),
      _buildMapRoute(),
      _buildCharacterRoute(),
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

  static GoRoute _buildMapRoute() {
    return GoRoute(
      path: map,
      name: map,
      pageBuilder: (context, state) => const NoTransitionPage(child: MapView()),
    );
  }

  static GoRoute _buildCharacterRoute() {
    return GoRoute(
      path: character,
      name: character,
      pageBuilder: (context, state) => const NoTransitionPage(child: CharacterView()),
    );
  }
}
