import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/theme/app_colors.dart';
import 'package:gunwave/theme/text_theme.dart';

final themeProvider = ChangeNotifierProvider<ThemeProvider>((ref) {
  throw UnimplementedError('ThemeProvider is not initialized');
});

class ThemeProvider extends ChangeNotifier{
  ThemeProvider._internal();
  static final ThemeProvider instance = ThemeProvider._internal();
  factory ThemeProvider() => instance;

  AppColors colors = DarkColors.instance;
  TextTheme textStyles = BaseTextTheme.textTheme;
  Brightness? systemBrightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;

  bool isDarkMode = true;
  ThemeData get themeData => ThemeData(
    colorScheme: colors.getColorScheme(),
    textTheme: textStyles,
  );

  void toggleThemeMode() {
    isDarkMode = !isDarkMode;
    colors = isDarkMode 
      ? DarkColors.instance
      : LightColors.instance;
    notifyListeners();
  }
}