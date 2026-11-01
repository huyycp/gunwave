import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:gunwave/data/constants/game/game_hud_style.dart';

/// Calculates thumb-control placement using the current window's safe insets.
abstract final class GameTouchControlLayout {
  /// Leaves the joystick's full diameter clear of the left and bottom insets.
  static EdgeInsets joystickMargin(EdgeInsets safeArea) => EdgeInsets.only(
    left: GameHudStyle.touchEdge + safeArea.left,
    bottom: GameHudStyle.touchEdge + safeArea.bottom,
  );

  /// Positions the attack target at the bottom-right safe corner.
  static Vector2 attackPosition(Vector2 viewportSize, EdgeInsets safeArea) =>
      Vector2(
        viewportSize.x -
            GameHudStyle.touchEdge -
            safeArea.right -
            GameHudStyle.touchAttackSize,
        viewportSize.y -
            GameHudStyle.touchEdge -
            safeArea.bottom -
            GameHudStyle.touchAttackSize,
      );

  /// Stacks the ability button one gap above attack on the same right edge.
  static EdgeInsets abilityInsets(EdgeInsets safeArea) => EdgeInsets.only(
    right: GameHudStyle.touchEdge + safeArea.right,
    bottom:
        GameHudStyle.touchEdge +
        GameHudStyle.touchAttackSize +
        GameHudStyle.touchControlGap +
        safeArea.bottom,
  );
}
