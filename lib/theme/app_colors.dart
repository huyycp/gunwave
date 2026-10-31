import 'package:flutter/material.dart';

const kColorPrimary        = Color(0xFF492BFF);
const kColorSecondary      = Color(0xFF8466FF);
const kColorAccent         = Color(0xFFCFC4FC);
const kColorOnPrimary      = Color(0xFFFDFFF8);
const kColorOnSecondary    = Color(0xFFFDFFF8);

const kColorInfo           = Color(0xFF51A1F6);
const kColorSuccess        = Color(0xFF5DC55B);
const kColorWarning        = Color(0xFFE9AB25);
const kColorError          = Color(0xFFFB384D);
const kColorOnError        = Color(0xFFFDFFF8);

const kColorSurface        = Color(0xFF01050F);
const kColorOnSurface      = Color(0xFFFDFFF8);

const kColorButton         = Color(0xFFF6F5FA);

const kGradient1 = LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [kColorPrimary, kColorSecondary]);

const kGradient2 = LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [kColorSecondary, kColorAccent]);

const kGradient3 = LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Color(0xFF3F3E6F), Color(0xFF211F48)]);

const kColorWhite = Colors.white;
const kColorBlack = Colors.black;
const kColorTransparent = Colors.transparent;

abstract class AppColors {
  Color get primaryBackground; 
  Color get secondaryBackground;
  Color get primaryText;
  Color get secondaryText;
  Color get alternate;     
  Color get border;
  Brightness get brightness;

  ColorScheme getColorScheme() {
    return ColorScheme(
      brightness: brightness,
      primary: kColorPrimary,
      onPrimary: kColorOnPrimary,
      secondary: kColorSecondary,
      onSecondary: kColorOnSecondary,
      error: kColorError,
      onError: kColorOnError,
      surface: primaryBackground,
      onSurface: primaryText,
      background: primaryBackground,
      onBackground: primaryText,
      outline: border,
    );
  }
}

/// Light mode
class LightColors extends AppColors{
  LightColors._();
  static final _instance = LightColors._();
  static LightColors get instance => _instance;

  @override
  final Color primaryBackground   = const Color(0xFFF5F6FA);
  @override
  final Color secondaryBackground = const Color(0xFFEFEEF3);
  @override
  final Color primaryText         = const Color(0xFF01050F);
  @override
  final Color secondaryText       = const Color(0xFF3E414A);
  @override
  final Color alternate           = const Color(0xFF7C7D84);
  @override
  final Color border              = const Color(0xFFD1D1D7);
  @override
  final Brightness brightness     = Brightness.light;
}

/// Dark mode
class DarkColors extends AppColors{
  DarkColors._();
  static final _instance = DarkColors._();
  static DarkColors get instance => _instance;

  @override
  final Color primaryBackground   = const Color(0xFF01050F);
  @override
  final Color secondaryBackground = const Color(0xFF151822);
  @override
  final Color primaryText         = const Color(0xFFF6F5FA);
  @override
  final Color secondaryText       = const Color(0xFFB9B9BF);
  @override
  final Color alternate           = const Color(0xFF7C7D84);
  @override
  final Color border              = const Color(0xFF262932);
  @override
  final Brightness brightness     = Brightness.dark;
}
