import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gunwave/views/character/character_view.dart';
import 'package:gunwave/views/create_room/create_room_view.dart';
import 'package:gunwave/views/home/home_view.dart';
import 'package:gunwave/views/my_room/my_room_view.dart';
import 'package:gunwave/views/rank/rank_view.dart';
import 'package:gunwave/views/room/room_view.dart';
import 'package:gunwave/views/shop/shop_view.dart';
import 'package:gunwave/views/splash/splash_view.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class Routes {

  static const splash = '/splash';
  static const home = '/home';
  static const map = '/map';
  static const character = '/character';
  static const shop = '/shop';
  static const myRoom = '/my-room';
  static const createRoom = '/create-room';
  static const rank = '/rank';

  static final GoRouter config = GoRouter(
    initialLocation: splash,
    debugLogDiagnostics: false,
    navigatorKey: navigatorKey,
    routes: [
      _buildSplashRoute(),
      _buildHomeRoute(),
      _buildMapRoute(),
      _buildCharacterRoute(),
      _buildShopRoute(),
      _buildMyRoomRoute(),
      _buildCreateRoomRoute(),
      _buildRankRoute(),
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
      pageBuilder: (context, state) => const NoTransitionPage(child: RoomView()),
    );
  }

  static GoRoute _buildCharacterRoute() {
    return GoRoute(
      path: character,
      name: character,
      pageBuilder: (context, state) => const NoTransitionPage(child: CharacterView()),
    );
  }

  static GoRoute _buildShopRoute() {
    return GoRoute(
      path: shop,
      name: shop,
      pageBuilder: (context, state) => const NoTransitionPage(child: ShopView()),
    );
  }

  static GoRoute _buildMyRoomRoute() {
    return GoRoute(
      path: myRoom,
      name: myRoom,
      pageBuilder: (context, state) => const NoTransitionPage(child: MyRoomView())
    );
  }

  static GoRoute _buildCreateRoomRoute() {
    return GoRoute(
      path: createRoom,
      name: createRoom,
      pageBuilder: (context, state) {
        final args = state.extra is Map<String, dynamic> ? state.extra as Map<String, dynamic> : {};
        return NoTransitionPage(child: CreateRoomView(args.isNotEmpty ? args['onSuccess']: (_) {}));
      },
    );
  }

  static GoRoute _buildRankRoute() {
    return GoRoute(
      path: rank,
      name: rank,
      pageBuilder: (context, state) {
        final args = state.extra is Map<String, dynamic> ? state.extra as Map<String, dynamic> : {};
        return NoTransitionPage(child: RankView(
          roomId: args['room_id'],
          userId: args['user_id']));
      } ,
    );
  }
}
