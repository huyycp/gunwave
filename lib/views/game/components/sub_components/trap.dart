import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:gunwave/data/constants/game/game_trap.dart';
import 'package:gunwave/views/game/gunwave.dart';

class Trap extends SpriteAnimationComponent with HasGameRef<Gunwave>, CollisionCallbacks {
  Trap({
    required this.trap,
    required super.position,
    required super.size,
  });

  final GameTrap trap;

  late final SpriteAnimation idleAni;


  double stepTime = 0.08;

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

    animation = idleAni;
    
  }
}