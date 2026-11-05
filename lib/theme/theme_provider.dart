import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/theme/app_colors.dart';

final themeProvider = ChangeNotifierProvider<ThemeProvider>((ref) {
  throw UnimplementedError('ThemeProvider is not initialized');
});

class ThemeProvider extends ChangeNotifier {
  ThemeProvider._internal();
  ThemeProvider.forTesting() : this._internal();
  static final ThemeProvider instance = ThemeProvider._internal();
  factory ThemeProvider() => instance;

  AppColors colors = DarkColors.instance;
  Brightness? systemBrightness =
      WidgetsBinding.instance.platformDispatcher.platformBrightness;

  bool isDarkMode = true;
  ThemeData get themeData =>
      ThemeData(useMaterial3: true, colorScheme: colors.getColorScheme());
  TextTheme get textStyles => themeData.textTheme;

  void toggleThemeMode() {
    isDarkMode = !isDarkMode;
    colors = isDarkMode ? DarkColors.instance : LightColors.instance;
    notifyListeners();
  }
}
