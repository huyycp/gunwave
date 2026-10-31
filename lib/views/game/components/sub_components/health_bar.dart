import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'package:gunwave/data/constants/game/game_hud_style.dart';

/// Monster HP with a numeric label kept upright when the sprite flips.
class HealthBar extends PositionComponent {
  HealthBar({
    required this.maxHealth,
    required this.currentHealth,
    required this.width,
    super.position,
  }) : super(size: Vector2(width, barHeight), anchor: Anchor.bottomCenter);

  static const barHeight = 8.0;
  static const textGap = 2.0;
  @override
  final double width;
  final int maxHealth;
  int currentHealth;
  final _bgPaint = Paint()..color = GameHudStyle.healthBackground;
  final _fgPaint = Paint()..color = GameHudStyle.healthFill;
  // TextComponent caches layout; monster HP text is not relaid out per frame.
  late final _label = TextComponent(
    text: label,
    textRenderer: TextPaint(
      style: const TextStyle(
        fontSize: GameHudStyle.labelFontSize,
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
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), _bgPaint);
    final ratio = maxHealth > 0
        ? (currentHealth / maxHealth).clamp(0.0, 1.0)
        : 0.0;
    canvas.drawRect(Rect.fromLTWH(0, 0, width * ratio, height), _fgPaint);
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
