import 'dart:math' as math;
import 'dart:ui';
import 'package:flame/components.dart';

/// Sweeps a point against a rectangle so fast projectiles cannot tunnel.
class ProjectileGeometry {
  ProjectileGeometry._();

  /// Returns the first hit fraction on the segment, or null for no intersection.
  static double? entry(Vector2 start, Vector2 end, Rect bounds) {
    var enter = 0.0;
    var exit = 1.0;
    for (final axis in [
      (start.x, end.x - start.x, bounds.left, bounds.right),
      (start.y, end.y - start.y, bounds.top, bounds.bottom),
    ]) {
      final (origin, delta, low, high) = axis;
      if (delta == 0) {
        if (origin < low || origin > high) return null;
        continue;
      }
      final a = (low - origin) / delta;
      final b = (high - origin) / delta;
      enter = math.max(enter, math.min(a, b));
      exit = math.min(exit, math.max(a, b));
      if (enter > exit) return null;
    }
    return enter;
  }
}
