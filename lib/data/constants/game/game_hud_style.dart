import 'package:flutter/material.dart';

/// Shared dimensions and contrast colors for the compact in-game HUD.
abstract final class GameHudStyle {
  static const edge = 6.0;
  static const gap = 6.0;
  static const panelPadding = 12.0;
  static const minimumTouchSize = 48.0;
  static const minimumGameplayUiScale = 1.0;
  static const compactButtonLabelMaxHeight = 52.0;
  static const prominentButtonLabelMinHeight = 60.0;
  static const minimumButtonLabelSize = 16.0;
  // Keep button labels from shrinking as quickly as controls on phone layouts.
  static const minimumButtonTextScale = 0.85;
  static const buttonLabelHorizontalInset = 4.0;
  // The Tiny Swords button's lower shadow puts its optical center above its
  // geometric center. This offset is measured at the medium asset height.
  static const buttonLabelOpticalReferenceHeight = 56.0;
  static const buttonLabelOpticalYOffset = -5.0;

  static double buttonLabelOpticalOffsetForHeight(double height) =>
      buttonLabelOpticalYOffset * height / buttonLabelOpticalReferenceHeight;
  static const uiFontScale = 1.0;
  static const playerPanelMaxWidth = 320.0;
  static const healthHeight = 20.0;
  static const healthWorldHeight = 10.0;
  static const joystickDiameter = 128.0;
  static const joystickKnobDiameter = 64.0;
  static const touchAttackSize = 72.0;
  static const touchEdge = 24.0;
  static const touchControlGap = 12.0;
  static const healthInset = 2.0;
  static const healthSeparatorWidth = 1.0;
  static const criticalHealthRatio = .25;
  static const abilitySize = 56.0;
  static const abilityIconSize = 26.0;
  static const healthBackground = Color(0xFF641C25);
  static const healthFill = Color(0xFF238B50);
  static const healthCriticalFill = Color(0xFFE64A3B);
  static const healthFrame = Color(0xFF1B1420);
  static const healthSeparator = Color(0x88211621);
  static const panel = Color(0xDB152134);
  static const foreground = Colors.white;
  static const damageTaken = Color(0xFFFF7777);
  static const damageDealt = Color(0xFFFFDB78);
}
