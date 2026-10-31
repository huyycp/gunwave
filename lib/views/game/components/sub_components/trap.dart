import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:gunwave/data/constants/game/game_effect.dart';
import 'package:gunwave/views/game/components/character.dart';
import 'package:gunwave/views/game/gunwave.dart';

class Trap extends SpriteAnimationComponent with HasGameRef<Gunwave>, CollisionCallbacks {
  Trap({
    required this.trap,
    required super.position,
    required super.size,
    this.isVisibleOnTriggered = false,
  });

  final GameEffects trap;

  // if true, trap will be visible when triggered
  // if false, trap will always be visible
  final bool isVisibleOnTriggered;
  
  late final SpriteAnimation idleAni;

  double stepTime = 0.08;

  // true damage
  int damage = 10;

  final hitbox = RectangleHitbox(
    position: Vector2(32, 32),
    size: Vector2(64, 76),
  );

  @override
  FutureOr<void> onLoad() {
    onLoadAnimations();
    return super.onLoad();
  }

  void onLoadAnimations() {
    idleAni = SpriteAnimation.fromFrameData(
      gameRef.images.fromCache(trap.path),
      SpriteAnimationData.sequenced(
        amount: 7,
        stepTime: stepTime,
        textureSize: Vector2.all(128),
      ),
    );

    add(hitbox);    

    if (isVisibleOnTriggered) opacity = 0;

    animation = idleAni;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Character) {
      if (other.hitbox.collidingWith(hitbox) && isVisibleOnTriggered) {
        opacity = 1;
      }
    }
    super.onCollision(intersectionPoints, other);
  }

}