import 'package:flutter/material.dart';

/// Shared dimensions and contrast colors for the compact in-game HUD.
abstract final class GameHudStyle {
  static const edge = 6.0;
  static const gap = 6.0;
  static const guideFontSize = 10.0;
  static const labelFontSize = 11.0;
  static const playerPanelMaxWidth = 320.0;
  static const healthHeight = 20.0;
  static const abilitySize = 56.0;
  // Match the existing 64px Flame attack control at right/bottom 66px.
  static const touchRight = 70.0;
  static const touchBottom = 142.0;
  static const healthBackground = Color(0xFF641C25);
  static const healthFill = Color(0xFF238B50);
  static const panel = Color(0xDB152134);
  static const foreground = Colors.white;
  static const damageTaken = Color(0xFFFF7777);
  static const damageDealt = Color(0xFFFFDB78);
}
