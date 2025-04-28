import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:gunwave/views/game/components/collision_component.dart';
import 'package:gunwave/views/game/gunwave.dart';

class BulletComponent extends SpriteAnimationGroupComponent
    with HasGameRef<Gunwave>, CollisionCallbacks {
  BulletComponent({
    required this.direction,
    super.position,
  });

  final int direction;
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation hitAnimation;

  late Vector2 velocity = Vector2(direction * 200, 0);
  // double moveSpeed = 200;

  bool isDead = false;

  @override
  Future<void> onLoad() async {

    _loadAnimation();

    priority = 100;

    add(CircleHitbox());

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (!isDead) {
      position += velocity * dt;
    }
    super.update(dt);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) async {
    
    if (other is CollisionComponent) {
      removeFromParent();
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  void _loadAnimation() {
    idleAnimation = SpriteAnimation.fromFrameData(
      game.images.fromCache('Other/Dust Particle.png'),
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 0.1,
        textureSize: Vector2.all(8),
        loop: false,
      ),
    );

    hitAnimation = SpriteAnimation.fromFrameData(
      game.images.fromCache('items/fruits/collected.png'),
      SpriteAnimationData.sequenced(
        amount: 6,
        stepTime: 0.1,
        textureSize: Vector2.all(12),
        loop: false,
      ),
    );

    animations = {
      BulletState.idle: idleAnimation,
      BulletState.hit: hitAnimation,
    };

    current = BulletState.idle;
  }
}

enum BulletState {
  idle,
  hit,
}