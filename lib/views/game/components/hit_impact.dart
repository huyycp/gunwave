import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Draws a brief pixel flash and a few square sparks where accepted damage lands.
class HitImpact extends PositionComponent {
  /// Creates a one-shot impact centered on the supplied combat position.
  HitImpact({
    required Vector2 origin,
    required double width,
    required double height,
  }) : super(
         position: origin.clone(),
         size: Vector2(width, height),
         anchor: Anchor.center,
         priority: 90,
       );

  static const duration = .12;
  static const maxVisible = 32;
  static const sparkSize = 4.0;
  static const flashExtent = .64;
  static const flashFillOpacity = .2;
  static const flashFrameOpacity = .7;
  static const sparkCount = 4;
  static const sparkInitialReach = .28;
  static const sparkReachGrowth = .28;
  static final _visible = Expando<int>();

  final Paint _paint = Paint()..isAntiAlias = false;
  Component? _owner;
  double _elapsed = 0;

  /// Adds bounded feedback to [world], ignoring missing or invalid hit bounds.
  static void show(
    Component? world,
    Vector2 origin, {
    required double width,
    required double height,
  }) {
    if (world == null ||
        !origin.x.isFinite ||
        !origin.y.isFinite ||
        !width.isFinite ||
        !height.isFinite ||
        width <= 0 ||
        height <= 0) {
      return;
    }
    final count = _visible[world] ?? 0;
    if (count >= maxVisible) return;
    _visible[world] = count + 1;
    world.add(
      HitImpact(origin: origin, width: width, height: height).._owner = world,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    if (_elapsed >= duration) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final progress = (_elapsed / duration).clamp(0.0, 1.0);
    final alpha = flashFrameOpacity * (1 - progress);
    final center = Offset(size.x / 2, size.y / 2);
    final flash = Rect.fromLTRB(
      _snap(size.x * (1 - flashExtent) / 2),
      _snap(size.y * (1 - flashExtent) / 2),
      _snap(size.x * (1 + flashExtent) / 2),
      _snap(size.y * (1 + flashExtent) / 2),
    );

    _paint
      ..style = PaintingStyle.fill
      ..color = Colors.white.withValues(alpha: alpha * flashFillOpacity);
    canvas.drawRect(flash, _paint);

    _paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = sparkSize
      ..color = Colors.white.withValues(alpha: alpha);
    canvas.drawRect(flash, _paint);

    _paint.style = PaintingStyle.fill;
    final reach =
        math.min(size.x, size.y) *
        (sparkInitialReach + progress * sparkReachGrowth);
    for (var i = 0; i < sparkCount; i++) {
      final angle = math.pi / 4 + i * math.pi / 2;
      final point = Offset(
        _snap(center.dx + math.cos(angle) * reach),
        _snap(center.dy + math.sin(angle) * reach),
      );
      canvas.drawRect(
        Rect.fromCenter(center: point, width: sparkSize, height: sparkSize),
        _paint,
      );
    }
  }

  double _snap(double coordinate) =>
      ((coordinate / sparkSize).round() * sparkSize).toDouble();

  @override
  void onRemove() {
    final owner = _owner;
    if (owner != null) {
      _visible[owner] = (_visible[owner] ?? 1) - 1;
      _owner = null;
    }
    super.onRemove();
  }
}
