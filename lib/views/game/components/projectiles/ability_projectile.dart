import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:gunwave/data/constants/game/game_constants.dart';
import 'package:gunwave/views/game/abilities/ability_visual_style.dart';
import 'package:gunwave/views/game/combat/combatant.dart';
import 'package:gunwave/views/game/components/monster.dart';
import 'package:gunwave/views/game/components/projectiles/projectile_geometry.dart';
import 'package:gunwave/views/game/gunwave.dart';

/// A swept projectile that stops at walls and hits each monster at most once.
class AbilityProjectile extends PositionComponent with HasGameRef<Gunwave> {
  AbilityProjectile(
      {required Vector2 origin,
      required Vector2 direction,
      required this.damage,
      required this.range,
      required this.piercing,
      this.visualStyle = AbilityVisualStyle.flameBrand})
      : direction = direction.normalized(),
        super(
            position: origin.clone(),
            size: Vector2.all(radius * 2),
            anchor: Anchor.center,
            priority: 10);

  // Small collision radius keeps the bolt visible without filling narrow paths.
  static const double radius = 6;
  static const double speed = GameConstants.tileSize * 8;
  final Vector2 direction;
  final int damage;
  final double range;
  final bool piercing;
  final AbilityVisualStyle visualStyle;
  final Set<Monster> _hit = {};
  double _travelled = 0;
  bool _finished = false;
  late final _paint = Paint()..color = visualStyle.color;

  @override
  void update(double dt) {
    if (_finished) return;
    super.update(dt);
    final distance = math.min(speed * dt, range - _travelled);
    final start = position.clone();
    final end = start + direction * distance;
    final swept =
        Rect.fromPoints(start.toOffset(), end.toOffset()).inflate(radius);
    double? wallHit;
    for (final wall in game.stage?.collisionGrid.query(swept) ?? {}) {
      final hit = ProjectileGeometry.entry(
          start,
          end,
          Rect.fromLTWH(wall.x, wall.y, wall.width, wall.height)
              .inflate(radius));
      if (hit != null && (wallHit == null || hit < wallHit)) wallHit = hit;
    }
    final hits = <(double, Monster)>[];
    for (final monster in game.stage?.monsters ?? <Monster>[]) {
      if (!monster.isAlive || _hit.contains(monster)) continue;
      final hit = ProjectileGeometry.entry(
          start,
          end,
          Rect.fromLTWH(monster.monsterX, monster.monsterY,
                  monster.hitbox.width, monster.hitbox.height)
              .inflate(radius));
      if (hit != null && (wallHit == null || hit < wallHit)) {
        hits.add((hit, monster));
      }
    }
    hits.sort((a, b) => a.$1.compareTo(b.$1));
    for (final (_, monster) in hits) {
      _hit.add(monster);
      monster.takeDamage(Damage(damage, source: DamageSource.ability));
      if (!piercing) {
        _finished = true;
        removeFromParent();
        return;
      }
    }
    position.setFrom(end);
    _travelled += distance;
    if (wallHit != null || _travelled >= range) {
      _finished = true;
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(radius, radius);
    canvas.rotate(math.atan2(direction.y, direction.x));
    if (visualStyle == AbilityVisualStyle.riftSlash) {
      _paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(Rect.fromCircle(center: Offset.zero, radius: radius * 1.5),
          -math.pi / 2, math.pi, false, _paint);
      _paint.color = visualStyle.color.withValues(alpha: .5);
      canvas.drawLine(const Offset(-radius * 3, 0), Offset.zero, _paint);
    } else {
      _paint.style = PaintingStyle.fill;
      _paint.color = visualStyle.color.withValues(alpha: .4);
      final flame = Path()
        ..moveTo(radius * 1.5, 0)
        ..quadraticBezierTo(-radius, -radius * 2, -radius * 3, 0)
        ..quadraticBezierTo(-radius, radius * 2, radius * 1.5, 0)
        ..close();
      canvas.drawPath(flame, _paint);
      _paint.color = visualStyle.color;
      canvas.drawCircle(Offset.zero, radius, _paint);
      _paint.color = Colors.yellowAccent;
      canvas.drawCircle(const Offset(radius * .25, 0), radius * .4, _paint);
    }
    _paint.color = visualStyle.color;
    canvas.restore();
  }
}
