import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gunwave/theme/app_typography.dart';

class BaseTextTheme {
  static final textTheme = TextTheme(
    displayLarge: DISPLAY_LARGE,
    displayMedium: DISPLAY_MEDIUM,
    displaySmall: DISPLAY_SMALL,
    headlineLarge: HEADLINE_LARGE,
    headlineMedium: HEADLINE_MEDIUM,
    headlineSmall: HEADLINE_SMALL,
    titleLarge: TITLE_LARGE,
    titleMedium: TITLE_MEDIUM,
    titleSmall: TITLE_SMALL,
    bodyLarge: BODY_LARGE,
    bodyMedium: BODY_MEDIUM,
    bodySmall: BODY_SMALL,
    labelLarge: LABEL_LARGE,
    labelMedium: LABEL_MEDIUM,
    labelSmall: LABEL_SMALL,
  );

  static final DISPLAY_LARGE = GoogleFonts.roboto(
    fontWeight: FontWeight.w600,
    fontSize: AppTypography.displaySize,
    height: AppTypography.headingLineHeight,
    letterSpacing: -0.25,
  );

  static final DISPLAY_MEDIUM = GoogleFonts.roboto(
    fontWeight: FontWeight.w600,
    fontSize: AppTypography.titleSize,
    height: AppTypography.headingLineHeight,
    letterSpacing: 0,
  );

  static final DISPLAY_SMALL = GoogleFonts.roboto(
    fontWeight: FontWeight.w600,
    fontSize: AppTypography.titleSize,
    height: AppTypography.headingLineHeight,
    letterSpacing: 0,
  );

  static final HEADLINE_LARGE = GoogleFonts.roboto(
    fontWeight: FontWeight.w600,
    fontSize: AppTypography.titleSize,
    height: AppTypography.headingLineHeight,
    letterSpacing: 0,
  );

  static final HEADLINE_MEDIUM = GoogleFonts.roboto(
    fontWeight: FontWeight.w400,
    fontSize: AppTypography.bodyLargeSize,
    height: AppTypography.headingLineHeight,
    letterSpacing: 0,
  );

  static final HEADLINE_SMALL = GoogleFonts.roboto(
    fontWeight: FontWeight.w400,
    fontSize: AppTypography.bodyLargeSize,
    height: AppTypography.headingLineHeight,
    letterSpacing: 0,
  );

  static final TITLE_LARGE = GoogleFonts.roboto(
    fontWeight: FontWeight.w600,
    fontSize: AppTypography.bodyLargeSize,
    height: AppTypography.headingLineHeight,
    letterSpacing: 0,
  );

  static final TITLE_MEDIUM = GoogleFonts.roboto(
    fontWeight: FontWeight.w600,
    fontSize: AppTypography.bodySize,
    height: AppTypography.compactLineHeight,
    letterSpacing: 0.15,
  );

  static final TITLE_MEDIUM_BOLD = GoogleFonts.roboto(
    fontWeight: FontWeight.w700,
    fontSize: AppTypography.bodySize,
    height: AppTypography.compactLineHeight,
    letterSpacing: 0.15,
  );

  static final TITLE_SMALL = GoogleFonts.roboto(
    fontWeight: FontWeight.w600,
    fontSize: AppTypography.bodySmallSize,
    height: AppTypography.compactLineHeight,
    letterSpacing: 0.1,
  );

  static final BODY_LARGE = GoogleFonts.roboto(
    fontWeight: FontWeight.w400,
    fontSize: AppTypography.bodyLargeSize,
    height: AppTypography.bodyLineHeight,
    letterSpacing: 0.5,
  );

  static final BODY_MEDIUM = GoogleFonts.roboto(
    fontWeight: FontWeight.w400,
    fontSize: AppTypography.bodySize,
    height: AppTypography.bodyLineHeight,
    letterSpacing: 0.25,
  );

  static final BODY_SMALL = GoogleFonts.roboto(
    fontWeight: FontWeight.w400,
    fontSize: AppTypography.bodySmallSize,
    height: AppTypography.bodyLineHeight,
    letterSpacing: 0.4,
  );

  static final LABEL_BUTTON = GoogleFonts.roboto(
    fontWeight: FontWeight.w600,
    fontSize: AppTypography.bodySmallSize,
    height: AppTypography.compactLineHeight,
    letterSpacing: 0.1,
  );

  static final LABEL_LARGE = GoogleFonts.roboto(
    fontWeight: FontWeight.w400,
    fontSize: AppTypography.bodySmallSize,
    height: AppTypography.compactLineHeight,
    letterSpacing: 0.1,
  );

  static final LABEL_MEDIUM = GoogleFonts.roboto(
    fontWeight: FontWeight.w400,
    fontSize: AppTypography.captionSize,
    height: AppTypography.compactLineHeight,
    letterSpacing: 0.5,
  );

  static final LABEL_MEDIUM_SEMIBOLD = GoogleFonts.roboto(
    fontWeight: FontWeight.w600,
    fontSize: AppTypography.captionSize,
    height: AppTypography.compactLineHeight,
    letterSpacing: 0.5,
  );

  static final LABEL_SMALL = GoogleFonts.roboto(
    fontWeight: FontWeight.w400,
    fontSize: AppTypography.captionSize,
    height: AppTypography.compactLineHeight,
    letterSpacing: 0.5,
  );
}
