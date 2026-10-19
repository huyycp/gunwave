import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/views/game/components/projectiles/projectile_geometry.dart';

void main() {
  const wall = Rect.fromLTWH(50, 0, 10, 20);
  test('swept movement hits thin walls even when the endpoint passes them', () {
    expect(
        ProjectileGeometry.entry(Vector2(0, 10), Vector2(1000, 10), wall), .05);
  });
  test('vertical and reversed travel return the first intersection', () {
    expect(
        ProjectileGeometry.entry(Vector2(55, -20), Vector2(55, 20), wall), .5);
    expect(
        ProjectileGeometry.entry(Vector2(100, 10), Vector2(0, 10), wall), .4);
  });
  test('nearby diagonal paths do not falsely hit bounding boxes', () {
    expect(ProjectileGeometry.entry(Vector2.zero(), Vector2(100, 100), wall),
        isNull);
  });
  test('parallel misses and targets behind the projectile are ignored', () {
    expect(ProjectileGeometry.entry(Vector2(0, 30), Vector2(100, 30), wall),
        isNull);
    expect(ProjectileGeometry.entry(Vector2(100, 10), Vector2(200, 10), wall),
        isNull);
  });
  test('starting inside a target registers an immediate hit', () {
    expect(
        ProjectileGeometry.entry(Vector2(55, 10), Vector2(100, 10), wall), 0);
  });
}
