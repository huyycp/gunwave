import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gunwave/data/constants/game/game_hud_style.dart';

/// Paints the shared hard-edged health bar used by both HUD and Flame actors.
class PixelHealthBarPainter extends CustomPainter {
  /// Creates a painter for the supplied current-to-maximum HP ratio.
  const PixelHealthBarPainter({required this.ratio});

  static const _markers = 3;
  static const _segments = _markers + 1;

  final double ratio;

  /// Chooses one shared fill color after safely normalizing a health ratio.
  static Color fillColorForRatio(double ratio) =>
      normalizedRatio(ratio) <= GameHudStyle.criticalHealthRatio
      ? GameHudStyle.healthCriticalFill
      : GameHudStyle.healthFill;

  /// Keeps invalid and out-of-range values from producing negative geometry.
  static double normalizedRatio(double ratio) =>
      ratio.isFinite ? ratio.clamp(0.0, 1.0) : 0;

  /// Draws a dark pixel frame, an HP fill, and three fixed quarter markers.
  static void draw(Canvas canvas, Rect bounds, double ratio) {
    if (bounds.width <= 0 || bounds.height <= 0) return;

    final paint = Paint()..isAntiAlias = false;
    paint.color = GameHudStyle.healthFrame;
    canvas.drawRect(bounds, paint);

    final inset = math.min(
      GameHudStyle.healthInset,
      math.min(bounds.width, bounds.height) / 2,
    );
    final inner = bounds.deflate(inset);
    if (inner.isEmpty) return;

    paint.color = GameHudStyle.healthBackground;
    canvas.drawRect(inner, paint);

    final normalized = normalizedRatio(ratio);
    final fillWidth = inner.width * normalized;
    if (fillWidth > 0) {
      paint.color = fillColorForRatio(normalized);
      canvas.drawRect(
        Rect.fromLTWH(inner.left, inner.top, fillWidth, inner.height),
        paint,
      );
    }

    paint.color = GameHudStyle.healthSeparator;
    for (var segment = 1; segment < _segments; segment++) {
      final x = (inner.left + inner.width * segment / _segments)
          .roundToDouble();
      canvas.drawRect(
        Rect.fromLTWH(
          x,
          inner.top,
          GameHudStyle.healthSeparatorWidth,
          inner.height,
        ),
        paint,
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) =>
      draw(canvas, Offset.zero & size, ratio);

  @override
  bool shouldRepaint(PixelHealthBarPainter oldDelegate) =>
      oldDelegate.ratio != ratio;
}
