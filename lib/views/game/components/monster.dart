import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:gunwave/data/constants/game/game_constants.dart';
import 'package:gunwave/data/constants/game/game_monster.dart';
import 'package:gunwave/views/game/gunwave.dart';

class Monster extends SpriteAnimationGroupComponent with HasGameRef<Gunwave>, CollisionCallbacks {
  Monster({
    required this.monster,
    required super.position,
    required super.size,
    required this.negXBound,
    required this.posXBound,
  });

  final GameMonster monster;
  final double negXBound;
  final double posXBound;

  late final SpriteAnimation idleAni;
  late final SpriteAnimation runAni;
  late final SpriteAnimation attack1Ani;
  late final SpriteAnimation attack2Ani;
  late final SpriteAnimation attack3Ani;

  Vector2 velocity = Vector2.zero();

  int horizontalMovement = 0;

  double stepTime = 0.08;
  double moveSpeed = 120;

  double accoumulatedTime = 0;

  late final double negXRange;
  late final double posXRange;

  @override
  Future<void> onLoad() async {
    onLoadAnimation();
    onLoadRange();

    add(RectangleHitbox(
      position: Vector2(64, 64),
      size: Vector2(64, 64),
    ));

    await super.onLoad();
  }

  @override
  void update(double dt) {
    accoumulatedTime += dt;
    while (accoumulatedTime > GameConstants.refreshRate) {

      updateMovement(GameConstants.refreshRate);
      updateState();
      
      super.update(GameConstants.refreshRate);
      accoumulatedTime -= GameConstants.refreshRate;
    }

    
  }

  void onLoadAnimation() {
    idleAni = _createAnimation(
      frameAmount: 7,
      texturePosition: Vector2(0, 0),
    );

    runAni = _createAnimation(
      frameAmount: 6,
      texturePosition: Vector2(0, 192),
    );

    attack1Ani = _createAnimation(
      frameAmount: 6,
      texturePosition: Vector2(0, 192 * 2),
    );

    attack2Ani = _createAnimation(
      frameAmount: 6,
      texturePosition: Vector2(0, 192 * 3),
    );

    attack3Ani = _createAnimation(
      frameAmount: 6,
      texturePosition: Vector2(0, 192 * 4),
    );

    animations = {
      MonsterState.idle: idleAni,
      MonsterState.run: runAni,
      MonsterState.attack1: attack1Ani,
      MonsterState.attack2: attack2Ani,
      MonsterState.attack3: attack3Ani,
    };

    current = MonsterState.idle;
  }

  SpriteAnimation _createAnimation({
    required int frameAmount,
    required Vector2 texturePosition,
    int? framePerRow,
    bool loop = true,
  }) {
  
    return SpriteAnimation.fromFrameData(
      game.images.fromCache(monster.path),
      SpriteAnimationData.sequenced(
        amount: frameAmount,
        amountPerRow: framePerRow,
        stepTime: stepTime,
        textureSize: Vector2(192, 192),
        texturePosition: texturePosition,
        loop: loop,
      ),
    );
  }

  void onLoadRange() {
    negXRange = position.x - negXBound;
    posXRange = position.x + width + posXBound;
  }

  void updateMovement(double dt) {
    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;
    if (position.x < negXRange) {
      position.x = negXRange;
    } else if (position.x > posXRange) {
      position.x = posXRange;
    }
    horizontalMovement *= -1;
  }

  void updateState() {
    if (horizontalMovement == 0) {
      current = MonsterState.idle;
    } else {
      if ((horizontalMovement > 0 && scale.x < 0) ||
          (horizontalMovement < 0 && scale.x > 0)) {
        flipHorizontallyAroundCenter();
      }
      current = MonsterState.run;
    }
  }
}

enum MonsterState {
  idle,
  run,
  attack1,
  attack2,
  attack3,
}

