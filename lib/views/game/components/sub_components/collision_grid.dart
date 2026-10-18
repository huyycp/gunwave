import 'dart:ui';

import 'package:gunwave/views/game/components/sub_components/collision_component.dart';

/// A uniform spatial index for the static collision rectangles in a stage.
class CollisionGrid {
  CollisionGrid({required this.cellSize});

  final double cellSize;
  final Map<(int, int), Set<CollisionComponent>> _cells = {};

  void add(CollisionComponent component) {
    for (var x = _cell(component.x);
        x <= _cell(component.x + component.width);
        x++) {
      for (var y = _cell(component.y);
          y <= _cell(component.y + component.height);
          y++) {
        _cells.putIfAbsent((x, y), () => <CollisionComponent>{}).add(component);
      }
    }
  }

  Set<CollisionComponent> query(Rect bounds) {
    final result = <CollisionComponent>{};
    for (var x = _cell(bounds.left); x <= _cell(bounds.right); x++) {
      for (var y = _cell(bounds.top); y <= _cell(bounds.bottom); y++) {
        result.addAll(_cells[(x, y)] ?? const <CollisionComponent>{});
      }
    }
    return result;
  }

  int _cell(double coordinate) => (coordinate / cellSize).floor();
}

/// Resolves a moving axis-aligned body against static rectangles, one axis at a time.
class AabbMovement {
  const AabbMovement._();

  static double resolveHorizontal({
    required double left,
    required double top,
    required double width,
    required double height,
    required double delta,
    required Iterable<Rect> obstacles,
  }) {
    var resolvedLeft = left + delta;
    if (delta == 0) return resolvedLeft;

    for (final obstacle in obstacles) {
      if (top >= obstacle.bottom || top + height <= obstacle.top) continue;
      if (delta > 0 &&
          left + width <= obstacle.left &&
          resolvedLeft + width > obstacle.left) {
        resolvedLeft = obstacle.left - width;
      } else if (delta < 0 &&
          left >= obstacle.right &&
          resolvedLeft < obstacle.right) {
        resolvedLeft = obstacle.right;
      }
    }
    return resolvedLeft;
  }

  static double resolveVertical({
    required double left,
    required double top,
    required double width,
    required double height,
    required double delta,
    required Iterable<Rect> obstacles,
  }) {
    var resolvedTop = top + delta;
    if (delta == 0) return resolvedTop;

    for (final obstacle in obstacles) {
      if (left >= obstacle.right || left + width <= obstacle.left) continue;
      if (delta > 0 &&
          top + height <= obstacle.top &&
          resolvedTop + height > obstacle.top) {
        resolvedTop = obstacle.top - height;
      } else if (delta < 0 &&
          top >= obstacle.bottom &&
          resolvedTop < obstacle.bottom) {
        resolvedTop = obstacle.bottom;
      }
    }
    return resolvedTop;
  }
}
