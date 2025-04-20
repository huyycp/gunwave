import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:gunwave/views/game/pixel_adventure.dart';

class SawComponent extends SpriteAnimationComponent with HasGameRef<PixelAdventure> {
  SawComponent({
    super.position,
    super.size,
    this.isVertical = false,
    this.negOffset = 0,
    this.posOffset = 0,
  });

  final bool isVertical;
  final double negOffset;
  final double posOffset;
  final double stepTime = 0.005;
  double minBound = 0;
  double maxBound = 0;
  int movementDirection = 1;
  final tileSize = 16;
  final moveSpeed = 100;

  @override
  FutureOr<void> onLoad() {
    _setRange();


    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('traps/Saw/On (38x38).png'),
      SpriteAnimationData.sequenced(
        amount: 8,
        stepTime: stepTime,
        textureSize: Vector2.all(38),
        loop: true,
      ),
    );

    add(CircleHitbox());
    
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isVertical) {
      position.y += movementDirection * moveSpeed * dt;
      if (position.y < minBound || position.y > maxBound) {
        movementDirection *= -1;
      }
    } else {
      position.x += movementDirection * moveSpeed * dt;
      if (position.x < minBound || position.x > maxBound) {
        movementDirection *= -1;
      }
    }
  }

  void _setRange() {
    if (isVertical) {
      minBound = position.y - negOffset * tileSize;
      maxBound = position.y + posOffset * tileSize;
    } else {
      minBound = position.x - negOffset * tileSize;
      maxBound = position.x + posOffset * tileSize;
    }
  }
}