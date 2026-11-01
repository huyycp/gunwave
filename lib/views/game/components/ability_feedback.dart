import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:gunwave/data/constants/game/game_constants.dart';
import 'package:gunwave/views/game/abilities/ability_visual_style.dart';
import 'package:gunwave/views/game/combat/combatant.dart';

/// Draws a distinct cast or status effect that follows its actor in world space.
///
/// Status feedback lasts until the corresponding modifier ends. Instant casts
/// expire after a short flash. Rendering uses a few block-based canvas draws,
/// without shaders, per-particle components or Flutter rebuilds.
class AbilityFeedback extends PositionComponent {
  AbilityFeedback({
    required this.style,
    required this.target,
    this.radius = GameConstants.tileSize / 2,
    Vector2? direction,
  }) : direction = (direction ?? Vector2(1, 0)).clone(),
       super(
         position: target.combatCenter.clone(),
         size: Vector2.all(radius * 2),
         anchor: Anchor.center,
         priority: 11,
       ) {
    _tracksStatus = target.effects[style.key] != null;
  }

  final AbilityVisualStyle style;
  final Combatant target;
  final double radius;
  final Vector2 direction;
  final Paint _paint = Paint()..isAntiAlias = false;
  late bool _tracksStatus;
  double _elapsed = 0;
  bool _finished = false;

  /// Pixel-grid spacing for ability effects in the 64-unit game tile.
  static const pixelCellSize = GameConstants.tileSize / 16;

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
    final progress = (_elapsed / GameConstants.abilityFeedbackDuration).clamp(
      0.0,
      1.0,
    );
    final alpha = _tracksStatus
        ? .7 + .2 * math.sin(_elapsed * math.pi * 2)
        : 1 - progress;
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
        _slash(canvas, progress, alpha);
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

  double get _cellSize => math.min(pixelCellSize, math.max(1, radius / 8));

  // Coordinates in the helpers below are pixel-cell units, then snapped once.
  void _pixel(Canvas canvas, int x, int y, double alpha, {int scale = 1}) {
    final cell = _cellSize;
    _paint
      ..color = style.color.withValues(alpha: alpha.clamp(0, 1))
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(x * cell, y * cell, cell * scale, cell * scale),
      _paint,
    );
  }

  void _pixelAt(
    Canvas canvas,
    double x,
    double y,
    double alpha, {
    int scale = 1,
  }) {
    _pixel(
      canvas,
      (x / _cellSize).round(),
      (y / _cellSize).round(),
      alpha,
      scale: scale,
    );
  }

  void _line(Canvas canvas, int x0, int y0, int x1, int y1, double alpha) {
    var x = x0;
    var y = y0;
    final dx = (x1 - x0).abs();
    final sx = x0 < x1 ? 1 : -1;
    final dy = -(y1 - y0).abs();
    final sy = y0 < y1 ? 1 : -1;
    var error = dx + dy;
    while (true) {
      _pixel(canvas, x, y, alpha);
      if (x == x1 && y == y1) break;
      final twiceError = 2 * error;
      if (twiceError >= dy) {
        error += dy;
        x += sx;
      }
      if (twiceError <= dx) {
        error += dx;
        y += sy;
      }
    }
  }

  /// Draws a compact shield silhouette with a brighter center seam.
  void _shield(Canvas canvas, double alpha) {
    const halfWidths = [2, 3, 3, 2, 2, 1];
    for (var row = 0; row < halfWidths.length; row++) {
      for (var column = -halfWidths[row]; column <= halfWidths[row]; column++) {
        _pixel(canvas, column, row - 3, alpha);
      }
    }
    _line(canvas, 0, -2, 0, 1, alpha * .55);
    _line(canvas, -1, -1, 1, -1, alpha * .55);
  }

  /// Draws a fractured strike mark and at most five remaining charge pips.
  void _power(Canvas canvas, double alpha) {
    for (var offset = -3; offset <= 3; offset++) {
      _pixel(canvas, offset, offset, alpha);
      _pixel(canvas, offset, -offset, alpha);
    }
    _line(canvas, -4, 0, 4, 0, alpha * .55);
    final charges = math.min(target.effects[style.key]?.charges ?? 3, 5);
    for (var i = 0; i < charges; i++) {
      _pixel(canvas, i - (charges - 1) ~/ 2, -6, alpha);
    }
  }

  /// Draws a jagged bolt and four short sparks for Thunder Crash.
  void _lightning(Canvas canvas, double progress, double alpha) {
    final fade = alpha * (.55 + progress * .45);
    _line(canvas, -1, -5, -1, -3, fade);
    _line(canvas, -1, -3, 1, -3, fade);
    _line(canvas, 1, -3, -1, 0, fade);
    _line(canvas, -1, 0, 1, 0, fade);
    _line(canvas, 1, 0, -1, 3, fade);
    _line(canvas, -1, 3, -1, 5, fade);
    for (var i = 0; i < 4; i++) {
      _pixel(canvas, i.isEven ? -4 : 3, i - 2, alpha * (1 - progress * .5));
    }
  }

  /// Orbits three block stars while the target remains stunned.
  void _stunStars(Canvas canvas, double alpha) {
    for (var i = 0; i < 3; i++) {
      final angle = _elapsed * 2 + i * math.pi * 2 / 3;
      final x = math.cos(angle) * radius * .55;
      final y = -radius * .8 + math.sin(angle) * radius * .15;
      _pixelAt(canvas, x, y - _cellSize, alpha);
      _pixelAt(canvas, x, y, alpha);
      _pixelAt(canvas, x - _cellSize, y, alpha);
      _pixelAt(canvas, x + _cellSize, y, alpha);
      _pixelAt(canvas, x, y + _cellSize, alpha);
    }
  }

  /// Draws two stepped arcs and fades them with the instant cast lifetime.
  void _slash(Canvas canvas, double progress, double alpha) {
    for (var i = 0; i <= 16; i++) {
      final angle = -1.15 + progress * .7 + i * 1.8 / 16;
      final outer = radius * .78;
      final inner = radius * .55;
      _pixelAt(canvas, math.cos(angle) * outer, math.sin(angle) * outer, alpha);
      if (i % 2 == 0) {
        _pixelAt(
          canvas,
          math.cos(angle) * inner,
          math.sin(angle) * inner,
          alpha * .7,
        );
      }
    }
  }

  /// Floats three pixel crosses upward to distinguish healing from damage.
  void _healing(Canvas canvas, double progress, double alpha) {
    for (var i = 0; i < 3; i++) {
      final x = (i - 1) * radius * .55;
      final y = radius * .2 - progress * radius - (i.isEven ? 0 : radius * .25);
      _pixelAt(canvas, x, y, alpha);
      _pixelAt(canvas, x - _cellSize, y, alpha);
      _pixelAt(canvas, x + _cellSize, y, alpha);
      _pixelAt(canvas, x, y - _cellSize, alpha);
      _pixelAt(canvas, x, y + _cellSize, alpha);
    }
  }

  /// Builds a small right-facing flame from stepped rows of square pixels.
  void _flame(Canvas canvas, double progress, double alpha) {
    final reach = 2 + (progress * 2).round();
    const rows = [-2, -1, 0, 1, 2];
    for (final row in rows) {
      final width = row == 0 ? reach + 2 : reach + 1 - row.abs() ~/ 2;
      for (var column = 0; column < width; column++) {
        _pixel(canvas, column - 2, row, alpha * (column < 2 ? .7 : 1));
      }
    }
    _pixel(canvas, 1, -3, alpha * .8);
    _pixel(canvas, 1, 3, alpha * .8);
  }

  /// Leaves staggered horizontal pixels behind the dash direction.
  void _dash(Canvas canvas, double alpha) {
    for (var row = -3; row <= 3; row++) {
      final length = 4 + row.abs() % 3;
      for (var column = -length; column <= -1; column++) {
        if ((column + row).isEven) _pixel(canvas, column, row, alpha);
      }
    }
    for (var column = -1; column <= 1; column++) {
      _pixel(canvas, column, -1, alpha * .65);
      _pixel(canvas, column, 0, alpha);
      _pixel(canvas, column, 1, alpha * .65);
    }
  }

  /// Draws a slowly stepped hex seal with a crossed center rune.
  void _rune(Canvas canvas, double alpha) {
    const corners = 6;
    final rotation = (_elapsed * 2).floor() % corners;
    final vertices = <(int, int)>[];
    for (var i = 0; i < corners; i++) {
      final angle = ((i + rotation) % corners) * math.pi * 2 / corners;
      vertices.add((
        (math.cos(angle) * 5).round(),
        (math.sin(angle) * 5).round(),
      ));
    }
    for (var i = 0; i < corners; i++) {
      final start = vertices[i];
      final end = vertices[(i + 1) % corners];
      _line(canvas, start.$1, start.$2, end.$1, end.$2, alpha);
    }
    _line(canvas, -2, -2, 2, 2, alpha * .8);
    _line(canvas, 2, -2, -2, 2, alpha * .8);
    _pixel(canvas, 0, 0, alpha);
  }
}
