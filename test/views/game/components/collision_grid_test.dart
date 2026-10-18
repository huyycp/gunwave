import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/views/game/components/sub_components/collision_component.dart';
import 'package:gunwave/views/game/components/sub_components/collision_grid.dart';

void main() {
  group('AabbMovement', () {
    const wall = Rect.fromLTWH(100, 0, 20, 120);
    const floor = Rect.fromLTWH(0, 100, 160, 20);

    test('stops horizontal movement before a wall without tunneling', () {
      final result = AabbMovement.resolveHorizontal(
        left: 20,
        top: 20,
        width: 30,
        height: 40,
        delta: 100,
        obstacles: [wall],
      );
      expect(result, 70);
    });

    test('stops leftward movement at the right edge of a wall', () {
      final result = AabbMovement.resolveHorizontal(
        left: 140,
        top: 20,
        width: 30,
        height: 40,
        delta: -80,
        obstacles: [wall],
      );
      expect(result, 120);
    });

    test('stops downward movement at the top of a floor', () {
      final result = AabbMovement.resolveVertical(
        left: 30,
        top: 40,
        width: 30,
        height: 30,
        delta: 80,
        obstacles: [floor],
      );
      expect(result, 70);
    });

    test('allows movement when the other axis does not overlap', () {
      final result = AabbMovement.resolveHorizontal(
        left: 20,
        top: 140,
        width: 30,
        height: 20,
        delta: 100,
        obstacles: [wall],
      );
      expect(result, 120);
    });
  });

  test('CollisionGrid returns nearby colliders once and excludes distant ones',
      () {
    final grid = CollisionGrid(cellSize: 64);
    final nearby = CollisionComponent(
      position: Vector2(60, 20),
      size: Vector2(20, 20),
    );
    final distant = CollisionComponent(
      position: Vector2(512, 512),
      size: Vector2(64, 64),
    );
    grid.add(nearby);
    grid.add(distant);

    final candidates = grid.query(const Rect.fromLTWH(64, 24, 16, 16));
    expect(candidates, {nearby});
  });
}
