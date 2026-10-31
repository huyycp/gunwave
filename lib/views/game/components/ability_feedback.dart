import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:gunwave/data/constants/game/game_constants.dart';
import 'package:gunwave/views/game/abilities/ability_visual_style.dart';
import 'package:gunwave/views/game/combat/combatant.dart';

/// Draws a distinct cast or status effect that follows its actor in world space.
///
/// Status feedback lasts until the corresponding modifier ends. Instant casts
/// expire after a short flash. Rendering uses a few canvas paths, without assets,
/// shaders, per-particle components or Flutter rebuilds.
class AbilityFeedback extends PositionComponent {
  AbilityFeedback(
      {required this.style,
      required this.target,
      this.radius = GameConstants.tileSize / 2,
      Vector2? direction})
      : direction = (direction ?? Vector2(1, 0)).clone(),
        super(
            position: target.combatCenter.clone(),
            size: Vector2.all(radius * 2),
            anchor: Anchor.center,
            priority: 11) {
    _tracksStatus = target.effects[style.key] != null;
  }

  final AbilityVisualStyle style;
  final Combatant target;
  final double radius;
  final Vector2 direction;
  final Paint _paint = Paint();
  late bool _tracksStatus;
  double _elapsed = 0;
  bool _finished = false;

  bool get isFinished => _finished;

  /// Restarts the cast flash while retaining one visual per actor and ability.
  void refresh() {
    _elapsed = 0;
    _tracksStatus = target.effects[style.key] != null;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_finished) return;
    _elapsed += dt;
    // The shockwave marks the cast location; status markers follow their actor.
    if (_tracksStatus || style != AbilityVisualStyle.thunderCrash) {
      position.setFrom(target.combatCenter);
    }
    if (!target.isAlive ||
        (_tracksStatus
            ? target.effects[style.key] == null
            : _elapsed >= GameConstants.abilityFeedbackDuration)) {
      _finished = true;
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    if (_finished) return;
    canvas.save();
    canvas.translate(radius, radius);
    final progress =
        (_elapsed / GameConstants.abilityFeedbackDuration).clamp(0.0, 1.0);
    final alpha = _tracksStatus
        ? .7 + .2 * math.sin(_elapsed * math.pi * 2)
        : 1 - progress;
    _stroke(alpha);
    switch (style) {
      case AbilityVisualStyle.bulwark:
        _shield(canvas, alpha);
      case AbilityVisualStyle.powerBreak:
        _power(canvas, alpha);
      case AbilityVisualStyle.thunderCrash:
        if (_tracksStatus) {
          _stunStars(canvas, alpha);
        } else {
          _lightning(canvas, progress, alpha);
        }
      case AbilityVisualStyle.riftSlash:
        canvas.rotate(math.atan2(direction.y, direction.x));
        _slash(canvas, progress);
      case AbilityVisualStyle.firstAid:
        _healing(canvas, progress, alpha);
      case AbilityVisualStyle.flameBrand:
        canvas.rotate(math.atan2(direction.y, direction.x));
        _flame(canvas, progress, alpha);
      case AbilityVisualStyle.quickstep:
        canvas.rotate(math.atan2(direction.y, direction.x));
        _dash(canvas, alpha);
      case AbilityVisualStyle.hexSeal:
        _rune(canvas, alpha);
    }
    canvas.restore();
  }

  void _stroke(double alpha, {double width = 3}) {
    _paint
      ..color = style.color.withValues(alpha: alpha.clamp(0, 1))
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
  }

  void _fill(double alpha) {
    _paint
      ..color = style.color.withValues(alpha: alpha.clamp(0, 1))
      ..style = PaintingStyle.fill;
  }

  void _shield(Canvas canvas, double alpha) {
    final path = Path()
      ..moveTo(0, -radius)
      ..lineTo(radius * .8, -radius * .6)
      ..lineTo(radius * .65, radius * .4)
      ..quadraticBezierTo(radius * .5, radius * .8, 0, radius)
      ..quadraticBezierTo(-radius * .5, radius * .8, -radius * .65, radius * .4)
      ..lineTo(-radius * .8, -radius * .6)
      ..close();
    _fill(alpha * .12);
    canvas.drawPath(path, _paint);
    _stroke(alpha);
    canvas.drawPath(path, _paint);
    canvas.drawLine(Offset(0, -radius * .55), Offset(0, radius * .5), _paint);
    canvas.drawLine(Offset(-radius * .35, -radius * .05),
        Offset(radius * .35, -radius * .05), _paint);
  }

  void _power(Canvas canvas, double alpha) {
    canvas.drawArc(Rect.fromCircle(center: Offset.zero, radius: radius),
        -.7 + _elapsed, math.pi, false, _paint);
    canvas.drawLine(Offset(-radius * .55, radius * .55),
        Offset(radius * .55, -radius * .55), _paint);
    canvas.drawLine(Offset(radius * .55, radius * .55),
        Offset(-radius * .55, -radius * .55), _paint);
    final charges = target.effects[style.key]?.charges ?? 3;
    // Limit drawn pips even if an administrator configures many attack charges.
    for (var i = 0; i < math.min(charges, 5); i++) {
      _fill(alpha);
      canvas.drawCircle(
          Offset((i - (math.min(charges, 5) - 1) / 2) * 9, -radius - 9),
          3,
          _paint);
    }
  }

  void _lightning(Canvas canvas, double progress, double alpha) {
    final reach = radius * (.15 + .85 * progress);
    canvas.drawCircle(Offset.zero, reach, _paint);
    const spokes = 8;
    for (var i = 0; i < spokes; i++) {
      final angle = i * math.pi * 2 / spokes;
      final path = Path()
        ..moveTo(math.cos(angle) * reach * .35, math.sin(angle) * reach * .35)
        ..lineTo(math.cos(angle + .2) * reach * .7,
            math.sin(angle + .2) * reach * .7)
        ..lineTo(math.cos(angle) * reach, math.sin(angle) * reach);
      canvas.drawPath(path, _paint);
    }
  }

  void _stunStars(Canvas canvas, double alpha) {
    const stars = 3;
    for (var i = 0; i < stars; i++) {
      final angle = _elapsed * 3 + i * math.pi * 2 / stars;
      final x = math.cos(angle) * radius * .7;
      final y = -radius + math.sin(angle) * radius * .2;
      final star = Path()
        ..moveTo(x, y - 5)
        ..lineTo(x + 2, y - 1)
        ..lineTo(x + 6, y)
        ..lineTo(x + 2, y + 2)
        ..lineTo(x, y + 6)
        ..lineTo(x - 2, y + 2)
        ..lineTo(x - 6, y)
        ..lineTo(x - 2, y - 1)
        ..close();
      _fill(alpha);
      canvas.drawPath(star, _paint);
    }
  }

  void _slash(Canvas canvas, double progress) {
    final angle = -1.2 + progress * 1.2;
    canvas.drawArc(Rect.fromCircle(center: Offset.zero, radius: radius), angle,
        1.8, false, _paint);
    canvas.drawArc(Rect.fromCircle(center: Offset.zero, radius: radius * .65),
        angle + .15, 1.4, false, _paint);
  }

  void _healing(Canvas canvas, double progress, double alpha) {
    const crosses = 3;
    for (var i = 0; i < crosses; i++) {
      final x = (i - 1) * radius * .65;
      final y = radius * .3 - progress * radius - (i.isEven ? 0 : radius * .4);
      _stroke(alpha, width: 4);
      canvas.drawLine(Offset(x - 5, y), Offset(x + 5, y), _paint);
      canvas.drawLine(Offset(x, y - 5), Offset(x, y + 5), _paint);
    }
  }

  void _flame(Canvas canvas, double progress, double alpha) {
    final reach = radius * (.6 + progress * .4);
    final path = Path()
      ..moveTo(reach, 0)
      ..quadraticBezierTo(0, -radius, -radius * .6, -radius * .35)
      ..quadraticBezierTo(-radius * .15, -radius * .05, -radius, 0)
      ..quadraticBezierTo(-radius * .1, radius * .7, reach, 0)
      ..close();
    _fill(alpha * .5);
    canvas.drawPath(path, _paint);
    _stroke(alpha);
    canvas.drawPath(path, _paint);
  }

  void _dash(Canvas canvas, double alpha) {
    const streaks = 4;
    for (var i = 0; i < streaks; i++) {
      final y = (i - 1.5) * radius * .4;
      _stroke(alpha * (1 - i * .15));
      canvas.drawLine(Offset(-radius * (1.6 + i * .25), y),
          Offset(-radius * .25, y), _paint);
    }
    _stroke(alpha * .5);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset.zero, width: radius, height: radius * 1.6),
        _paint);
  }

  void _rune(Canvas canvas, double alpha) {
    canvas.save();
    canvas.rotate(_elapsed * .6);
    final rune = Path();
    const corners = 6;
    for (var i = 0; i < corners; i++) {
      final angle = i * math.pi * 2 / corners;
      final x = math.cos(angle) * radius;
      final y = math.sin(angle) * radius;
      if (i == 0) {
        rune.moveTo(x, y);
      } else {
        rune.lineTo(x, y);
      }
    }
    rune.close();
    canvas.drawPath(rune, _paint);
    canvas.drawLine(Offset(-radius * .4, -radius * .4),
        Offset(radius * .4, radius * .4), _paint);
    canvas.drawLine(Offset(radius * .4, -radius * .4),
        Offset(-radius * .4, radius * .4), _paint);
    canvas.drawCircle(Offset.zero, radius * .4, _paint);
    canvas.restore();
  }
}
