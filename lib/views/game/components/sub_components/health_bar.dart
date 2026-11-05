import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'package:gunwave/data/constants/game/game_hud_style.dart';
import 'package:gunwave/theme/app_typography.dart';
import 'package:gunwave/views/game/components/sub_components/pixel_health_bar_painter.dart';

/// Monster HP with a numeric label kept upright when the sprite flips.
class HealthBar extends PositionComponent {
  HealthBar({
    required this.maxHealth,
    required int currentHealth,
    required this.width,
    super.position,
  }) : currentHealth = currentHealth.clamp(0, maxHealth > 0 ? maxHealth : 0),
       super(size: Vector2(width, barHeight), anchor: Anchor.bottomCenter);

  static const barHeight = GameHudStyle.healthWorldHeight;
  static const textGap = 2.0;
  @override
  final double width;
  final int maxHealth;
  int currentHealth;

  /// Current fill ratio after the configured HP bounds have been applied.
  double get healthRatio => maxHealth > 0
      ? PixelHealthBarPainter.normalizedRatio(currentHealth / maxHealth)
      : 0;
  // TextComponent caches layout; monster HP text is not relaid out per frame.
  late final _label = TextComponent(
    text: label,
    textRenderer: TextPaint(
      style: const TextStyle(
        fontSize: AppTypography.captionSize,
        color: GameHudStyle.foreground,
        fontWeight: FontWeight.bold,
        shadows: [Shadow(blurRadius: 2, color: Colors.black)],
      ),
    ),
    position: Vector2(width / 2, -textGap),
    anchor: Anchor.bottomCenter,
  );
  String get label => '$currentHealth / $maxHealth';

  @override
  void render(Canvas canvas) {
    PixelHealthBarPainter.draw(
      canvas,
      Rect.fromLTWH(0, 0, width, height),
      healthRatio,
    );
    canvas.save();
    if (parent is PositionComponent &&
        (parent! as PositionComponent).scale.x < 0) {
      canvas.translate(width, 0);
      canvas.scale(-1, 1);
    }
    _label.renderTree(canvas);
    canvas.restore();
    super.render(canvas);
  }

  void updateHealth(int newHealth) {
    currentHealth = newHealth.clamp(0, maxHealth > 0 ? maxHealth : 0);
    _label.text = label;
  }
}
