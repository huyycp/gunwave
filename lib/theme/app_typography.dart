import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Material 3 type-scale tokens mirrored for bitmap and pixel text.
abstract final class AppTypography {
  static const double displayLargeSize = 57;
  static const double displayMediumSize = 45;
  static const double displaySmallSize = 36;
  static const double headlineLargeSize = 32;
  static const double headlineMediumSize = 28;
  static const double headlineSmallSize = 24;
  static const double titleLargeSize = 22;
  static const double titleMediumSize = 16;
  static const double titleSmallSize = 14;
  static const double bodyLargeSize = 16;
  static const double bodyMediumSize = 14;
  static const double bodySmallSize = 12;
  static const double labelLargeSize = 14;
  static const double labelMediumSize = 12;
  static const double labelSmallSize = 11;

  static const double displayLargeLineHeight = 1.12;
  static const double displayMediumLineHeight = 1.16;
  static const double displaySmallLineHeight = 1.22;
  static const double headlineLargeLineHeight = 1.25;
  static const double headlineMediumLineHeight = 1.29;
  static const double headlineSmallLineHeight = 1.33;
  static const double titleLargeLineHeight = 1.27;
  static const double titleMediumLineHeight = 1.5;
  static const double titleSmallLineHeight = 1.43;
  static const double bodyLargeLineHeight = 1.5;
  static const double bodyMediumLineHeight = 1.43;
  static const double bodySmallLineHeight = 1.33;
  static const double labelLargeLineHeight = 1.43;
  static const double labelMediumLineHeight = 1.33;
  static const double labelSmallLineHeight = 1.45;

  static const double bitmapFontBaseSize = 14;
  static const double minimumBitmapFontSize = bodySmallSize;

  /// Converts a Material text size to the project's bitmap-atlas scale.
  static double bitmapScale(double fontSize, {double responsiveScale = 1}) {
    final responsiveFontSize = math.max(
      fontSize * responsiveScale,
      minimumBitmapFontSize,
    );
    return responsiveFontSize / bitmapFontBaseSize;
  }

  /// Creates a Press Start 2P accent style for pixel-art Flutter surfaces.
  static TextStyle pixelStyle({
    required double fontSize,
    double height = bodyMediumLineHeight,
    Color? color,
    FontWeight? fontWeight,
  }) => GoogleFonts.pressStart2p(
    fontSize: fontSize,
    height: height,
    color: color,
    fontWeight: fontWeight,
  );
}
