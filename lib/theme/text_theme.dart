import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    fontSize: 57,
    height: 64/57,
    letterSpacing: -0.25,
  );

  static final DISPLAY_MEDIUM = GoogleFonts.roboto(
    fontWeight: FontWeight.w600,
    fontSize: 45,
    height: 52/45,
    letterSpacing: 0,
  );

  static final DISPLAY_SMALL = GoogleFonts.roboto(
    fontWeight: FontWeight.w600,
    fontSize: 36,
    height: 44/36,
    letterSpacing: 0,
  );

  static final HEADLINE_LARGE = GoogleFonts.roboto(
    fontWeight: FontWeight.w600,
    fontSize: 32,
    height: 40/32,
    letterSpacing: 0,
  );

  static final HEADLINE_MEDIUM = GoogleFonts.roboto(
    fontWeight: FontWeight.w400,
    fontSize: 28,
    height: 36/28,
    letterSpacing: 0,
  );

  static final HEADLINE_SMALL = GoogleFonts.roboto(
    fontWeight: FontWeight.w400,
    fontSize: 24,
    height: 32/24,
    letterSpacing: 0,
  );

  static final TITLE_LARGE = GoogleFonts.roboto(
    fontWeight: FontWeight.w600,
    fontSize: 22,
    height: 28/22,
    letterSpacing: 0,
  );

  static final TITLE_MEDIUM = GoogleFonts.roboto(
    fontWeight: FontWeight.w600,
    fontSize: 16,
    height: 24/16,
    letterSpacing: 0.15,
  );

  static final TITLE_MEDIUM_BOLD = GoogleFonts.roboto(
    fontWeight: FontWeight.w700,
    fontSize: 16,
    height: 24/16,
    letterSpacing: 0.15,
  );

  static final TITLE_SMALL = GoogleFonts.roboto(
    fontWeight: FontWeight.w600,
    fontSize: 14,
    height: 20/14,
    letterSpacing: 0.1,
  );

  static final BODY_LARGE = GoogleFonts.roboto(
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 24/16,
    letterSpacing: 0.5,
  );

  static final BODY_MEDIUM = GoogleFonts.roboto(
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 20/14,
    letterSpacing: 0.25,
  );

  static final BODY_SMALL = GoogleFonts.roboto(
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 16/12,
    letterSpacing: 0.4,
  );

  static final LABEL_BUTTON = GoogleFonts.roboto(
    fontWeight: FontWeight.w600,
    fontSize: 14,
    height: 20/14,
    letterSpacing: 0.1,
  );

  static final LABEL_LARGE = GoogleFonts.roboto(
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 20/14,
    letterSpacing: 0.1,
  );

  static final LABEL_MEDIUM = GoogleFonts.roboto(
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 16/12,
    letterSpacing: 0.5,
  );

  static final LABEL_MEDIUM_SEMIBOLD = GoogleFonts.roboto(
    fontWeight: FontWeight.w600,
    fontSize: 12,
    height: 16/12,
    letterSpacing: 0.5,
  );

  static final LABEL_SMALL = GoogleFonts.roboto(
    fontWeight: FontWeight.w400,
    fontSize: 11,
    height: 16/11,
    letterSpacing: 0.5,
  );
}