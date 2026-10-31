import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gunwave/routes.dart';
import 'package:gunwave/theme/app_colors.dart';
import 'package:gunwave/theme/theme_provider.dart';


extension BuildContextEx on BuildContext {
  AppColors get appColors => ProviderScope.containerOf(this).read(themeProvider).colors;
  TextTheme get textStyles => ProviderScope.containerOf(this).read(themeProvider).textStyles;

  // Landscape layout = width > height
  bool get isLandscapeLayout {
    return MediaQuery.of(this).size.width > MediaQuery.of(this).size.height;
  }

  Future<T?> pushReplacement<T extends Object?>(Widget page) {
    return Navigator.of(this).pushReplacement(MaterialPageRoute(builder: (context) => page));
  }

  Future<T?> pushAndRemoveUntil<T extends Object?>(Widget page, {RoutePredicate? predicate}) {
    return Navigator.of(this).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => page), predicate ?? (route) => false);
  }

  Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    String routeName, {
    Object? arguments,
    String? matchedRouteName,
  }) async {
    while(location != matchedRouteName) {
      pop();
    }
    return push(routeName, extra: arguments);
  }

  String get location {
    final RouteMatch lastMatch = Routes.config.routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : Routes.config.routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}
