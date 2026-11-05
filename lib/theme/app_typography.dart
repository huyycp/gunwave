import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shared size and rhythm tokens for Flutter and Flame interface text.
abstract final class AppTypography {
  static const double captionSize = 12;
  static const double bodySmallSize = 14;
  static const double bodySize = 16;
  static const double bodyLargeSize = 18;
  static const double titleSize = 24;
  static const double displaySize = 32;

  // RPG menus use larger bitmap sizes than supporting app and HUD labels.
  static const double rpgCaptionSize = 16;
  static const double rpgBodySmallSize = 18;
  static const double rpgBodySize = 20;
  static const double rpgBodyLargeSize = 22;
  static const double rpgTitleSize = 28;
  static const double rpgButtonSize = 18;

  static const double bitmapFontBaseSize = 14;
  static const double minimumBitmapFontSize = captionSize;

  static const double headingLineHeight = 1.2;
  static const double bodyLineHeight = 1.5;
  static const double compactLineHeight = 4 / 3;

  /// Converts a requested pixel size to the project's bitmap atlas scale.
  ///
  /// Responsive layouts may reduce surrounding controls, but bitmap text is
  /// kept at least [minimumBitmapFontSize] logical pixels tall for legibility.
  static double bitmapScale(double fontSize, {double responsiveScale = 1}) {
    final responsiveFontSize = math.max(
      fontSize * responsiveScale,
      minimumBitmapFontSize,
    );
    return responsiveFontSize / bitmapFontBaseSize;
  }

  /// Creates a Press Start 2P accent style for legacy Flutter pixel screens.
  static TextStyle pixelStyle({
    required double fontSize,
    Color? color,
    FontWeight? fontWeight,
  }) => GoogleFonts.pressStart2p(
    fontSize: fontSize,
    height: compactLineHeight,
    color: color,
    fontWeight: fontWeight,
  );
}
