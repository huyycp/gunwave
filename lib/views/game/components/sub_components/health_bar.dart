import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class HealthBar extends PositionComponent {
  HealthBar({
    required this.maxHealth,
    required this.currentHealth,
    required this.width,
    super.position,
  }) : super(
          size: Vector2(width, 8), // Height of 8 pixels
          anchor: Anchor.bottomCenter,
        );

  @override
  final double width;
  final int maxHealth;
  int currentHealth;
  
  // Colors for the health bar
  final Paint _bgPaint = Paint()..color = Colors.red.shade900;
  final Paint _fgPaint = Paint()..color = Colors.green;

  @override
  void render(Canvas canvas) {
    // Draw background (empty health)
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, size.y),
      _bgPaint,
    );
    
    // Draw foreground (filled health)
    final double healthPercentage = currentHealth / maxHealth;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width * healthPercentage, size.y),
      _fgPaint,
    );
    
    super.render(canvas);
  }

  void updateHealth(int newHealth) {
    currentHealth = newHealth;
  }
}