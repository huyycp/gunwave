import 'dart:async';
import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:gunwave/data/constants/game/game_character.dart';
import 'package:gunwave/data/constants/game/game_constants.dart';
import 'package:gunwave/data/constants/game/game_effect.dart';
import 'package:gunwave/utils/app_math.dart';
import 'package:gunwave/views/game/components/sub_components/collision_component.dart';
import 'package:gunwave/views/game/components/monster.dart';
import 'package:gunwave/views/game/components/sub_components/health_bar.dart';
import 'package:gunwave/views/game/components/sub_components/trap.dart';
import 'package:gunwave/views/game/gunwave.dart';

class Character extends SpriteAnimationGroupComponent with HasGameRef<Gunwave>, KeyboardHandler, CollisionCallbacks {
  
  Character(this.character);

  final GameCharacters character;
  
  final double stepTime = 0.08;
  late final SpriteAnimation idleAni;
  late final SpriteAnimation runAni;
  late final SpriteAnimation attach1Ani;
  late final SpriteAnimation attach2Ani;
  late final SpriteAnimation attachTop1Ani;
  late final SpriteAnimation attachTop2Ani;
  late final SpriteAnimation attachBot1Ani;
  late final SpriteAnimation attachBot2Ani;
  List<CollisionComponent> collisionComponents = [];
  
  final spawnPosition = Vector2.zero();

  double moveSpeed = 150;
  Vector2 velocity = Vector2.zero();

  /// Value : -1, 0, 1
  /// 
  /// -1 = left, 0 = none, 1 = right
  int horizontalMovement = 0;

  /// Value : -1, 0, 1
  /// 
  /// -1 = up, 0 = none, 1 = down
  int verticalMovement = 0;

  bool triggerAttack = false;
  bool isAttacking = false;
  bool isAttackAvailable = false;
  bool isDoubleAttack = false;

  int hp = 200;
  int str = 50;

  final hitbox = RectangleHitbox(
    position: Vector2(72, 72),
    size: Vector2(48, 56),
  );

  late final attackbox = PolygonHitbox(
    [
      Vector2(hitbox.x + hitbox.width, 64 / 3),
      Vector2(64 + 64 + 64 * 2 / 3, 64),
      Vector2(64 + 64 + 64 * 4 / 5, 64 * 3 / 2),
      Vector2(64 + 64 + 64 * 4 / 5, 64 * 2),
      Vector2(hitbox.x + hitbox.width, 64 * 2),
    ],
  );

  late final movebox = RectangleHitbox(
    position: Vector2(hitbox.x, hitbox.y + hitbox.height / 2),
    size: Vector2(hitbox.width, hitbox.height / 2),
  );

  Map<String, int> collectedFruits = {};

  double accoumulatedTime = 0;

  double get characterX => scale.x > 0 ? position.x + hitbox.x : position.x - hitbox.x - hitbox.width;
  double get characterY => position.y + hitbox.y;

  bool get isDead => hp <= 0;

  int getHitRefreshTime = 500;

  late final healthBar = HealthBar(
    maxHealth: hp,
    currentHealth: hp,
    width: 60,
    position: Vector2(hitbox.x + hitbox.width / 2, hitbox.y - 20), // Position above head
  );

  late final fireEffect = SpriteAnimationComponent(
    animation: SpriteAnimation.fromFrameData(
      game.images.fromCache(GameEffects.fire.path),
      SpriteAnimationData.sequenced(
        amount: 7, // Adjust frame count as needed
        stepTime: 0.08, // Adjust animation speed as needed
        textureSize: Vector2(128, 128),
        loop: true,
      ),
    ),
    size: Vector2(48, 48),
    position: Vector2(hitbox.x + hitbox.width / 2 - 24, hitbox.y), // Position above head
  );

  @override
  FutureOr<void> onLoad() {
    onLoadAnimation();

    spawnPosition.x = position.x;
    spawnPosition.y = position.y;

    add(hitbox);
    add(attackbox);
    add(movebox);

    add(healthBar);

    priority = 5;
    
    return super.onLoad();
  }

  @override
  void update(double dt) {
    accoumulatedTime += dt;
    while (accoumulatedTime > GameConstants.refreshRate) {
      super.update(GameConstants.refreshRate);
      _updateCharacterMovement(GameConstants.refreshRate);
      attack();
      _updateCharacterState(GameConstants.refreshRate);
      _updateCharacterCollision();
      // debugPrint('attack: $isAttacking');
      accoumulatedTime -= GameConstants.refreshRate;
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final isLeftKeyPressed = 
      keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
      keysPressed.contains(LogicalKeyboardKey.keyA);
    final isRightKeyPressed =
      keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
      keysPressed.contains(LogicalKeyboardKey.keyD);
    final isUpKeyPressed =
      keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
      keysPressed.contains(LogicalKeyboardKey.keyW);
    final isDownKeyPressed =
      keysPressed.contains(LogicalKeyboardKey.arrowDown) ||
      keysPressed.contains(LogicalKeyboardKey.keyS);

    if ((isLeftKeyPressed && isRightKeyPressed) ||
        (isUpKeyPressed && isDownKeyPressed)) {
      horizontalMovement = 0;
      verticalMovement = 0;
    } else {
      if (isLeftKeyPressed) {
        horizontalMovement = -1;
      } else if (isRightKeyPressed) {
        horizontalMovement = 1;
      } else {
        horizontalMovement = 0;
      } 
      if (isUpKeyPressed) {
        verticalMovement = -1;
      } else if (isDownKeyPressed) {
        verticalMovement = 1;
      } else {
        verticalMovement = 0;
      }
    }

    if (event.logicalKey == LogicalKeyboardKey.keyJ) {
      triggerAttack = event is KeyDownEvent;
    }
    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Monster) {
      if (
        isAttackAvailable && 
        other.hitbox.collisionType == CollisionType.active &&
        attackbox.collidingWith(other.hitbox) &&
       !other.isDead
      ) {
        other.hp -= str;
        other.healthBar.updateHealth(other.hp);
        other.setInvicible();
        debugPrint('Monster HP: ${other.hp}');
      }

      if (
        other.current == MonsterState.attack1 &&
        hitbox.collisionType == CollisionType.active && 
        !isDead
        // other.attackbox.collidingWith(hitbox)
      ) {
        hp -= other.str;
        healthBar.updateHealth(hp);
        setInvicible();
        debugPrint('Character HP: $hp');
      }
    }
    if (other is Trap) {
      if (other.trap == GameEffects.fire) {
        if (
          other.hitbox.collidingWith(hitbox) &&
          hitbox.collisionType == CollisionType.active && 
          !isDead
        ) {
          hp -= other.damage;
          healthBar.updateHealth(hp);
          setInvicible();
          setFireEffect();
          debugPrint('Character HP: $hp');
        }
      }
    }
    super.onCollision(intersectionPoints, other);
  }

  void onLoadAnimation() {
    idleAni       = _createAnimation(frameAmount: 6, loop: true, texturePosition: Vector2(0, 0));
    runAni        = _createAnimation(frameAmount: 6, loop: true, texturePosition: Vector2(0, 192));
    attach1Ani    = _createAnimation(frameAmount: 6, loop: false, texturePosition: Vector2(0, 192 * 2));
    attach2Ani    = _createAnimation(frameAmount: 6, loop: false, texturePosition: Vector2(0, 192 * 3));
    attachTop1Ani = _createAnimation(frameAmount: 6, loop: false, texturePosition: Vector2(0, 192 * 4));
    attachTop2Ani = _createAnimation(frameAmount: 6, loop: false, texturePosition: Vector2(0, 192 * 5));
    attachBot1Ani = _createAnimation(frameAmount: 6, loop: false, texturePosition: Vector2(0, 192 * 6));
    attachBot2Ani = _createAnimation(frameAmount: 6, loop: false, texturePosition: Vector2(0, 192 * 7));

    animations = {
      GameCharacterStates.idle: idleAni,
      GameCharacterStates.run: runAni,
      GameCharacterStates.attack1: attach1Ani,
      GameCharacterStates.attack2: attach2Ani,
      GameCharacterStates.attackTop1: attachTop1Ani,
      GameCharacterStates.attackTop2: attachTop2Ani,
      GameCharacterStates.attackBot1: attachBot1Ani,
      GameCharacterStates.attackBot2: attachBot2Ani,
    };

    current = GameCharacterStates.idle;
  }

  SpriteAnimation _createAnimation({
    required int frameAmount,
    required Vector2 texturePosition,
    int? framePerRow,
    bool loop = true,
  }) {
  
    return SpriteAnimation.fromFrameData(
      game.images.fromCache(character.path),
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

  void _updateCharacterState(double dt) {
    if (isDead) removeFromParent();
    if (velocity.x == 0 && velocity.y == 0) {
      if (!isAttacking) current = GameCharacterStates.idle;
    } else {
      final isMovingLeft = velocity.x < 0;
      final isMovingRight = velocity.x > 0;
      if (
        (isMovingLeft && scale.x > 0) || 
        (isMovingRight && scale.x < 0)
      ) {
        flipHorizontallyAroundCenter();
      }
      if (!isAttacking) current = GameCharacterStates.run;
    }
  }

  void _updateCharacterMovement(double dt) {
    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;

    velocity.y = verticalMovement * moveSpeed;
    position.y += velocity.y * dt;
  }
  
  void _updateCharacterCollision() {
    for (var component in collisionComponents) {
      if (checkCollision(component)) {

        final aPoint = Vector2(component.x - movebox.width, component.y - movebox.height);
        final bPoint = Vector2(component.x + component.width, component.y - movebox.height);
        final cPoint = Vector2(component.x + component.width, component.y + component.height);
        final dPoint = Vector2(component.x - movebox.width, component.y + component.height);
        
        double angCB = calculateAngle(cPoint, component.position, bPoint);
        double angCA = calculateAngle(cPoint, component.position, aPoint);
        double angCD = calculateAngle(cPoint, component.position, dPoint);

        if (angCB < 0) angCB += 2 * pi;
        if (angCA < 0) angCA += 2 * pi;
        if (angCD < 0) angCD += 2 * pi;

        debugPrint('component: ${component.position}');
        debugPrint('movebox: ${movebox.position}');

        debugPrint('angCB: ${angCB * 180 / pi}');
        debugPrint('angCA: ${angCA * 180 / pi}');
        debugPrint('angCD: ${angCD * 180 / pi}');

        double angCChar = calculateAngle(cPoint, component.position, Vector2(characterX - hitbox.x + movebox.x, characterY - hitbox.y + movebox.y));

        
        if (angCChar < 0) angCChar += 2 * pi;

        debugPrint('angChar: ${angCChar * 180 / pi}');

        if (angCChar >= 0 && angCChar < angCB) {
          // right
          debugPrint('right');
          position.x = scale.x > 0 
            ? component.x + component.width - movebox.x
            : component.x + component.width + movebox.width + movebox.x;
        } else if (angCChar >= angCB && angCChar < angCA) {
          // top
          debugPrint('top');
          position.y = component.y - movebox.height - movebox.y;
        } else if (angCChar >= angCA && angCChar < angCD) {
          // left
          debugPrint('left');
          position.x = scale.x > 0
            ? component.x - movebox.width - movebox.x
            : component.x + movebox.x;
        } else if (angCChar >= angCD && angCChar < 2 * pi) {
          // bottom
          debugPrint('bottom');
          position.y = component.y + component.height - movebox.y;
        }
      }
    }
  }

  void attack({bool isDouble = false}) {

    if (triggerAttack) {
      if ([
        GameCharacterStates.attack1,
        GameCharacterStates.attack2,
        GameCharacterStates.attackTop1,
        GameCharacterStates.attackTop2,
        GameCharacterStates.attackBot1,
        GameCharacterStates.attackBot2,
      ].contains(current)) {
        return;
      }
      isAttacking = true;
      current = GameCharacterStates.attack1;
      debugPrint('attack');
      animationTicker?.onFrame = (frame) {
        if ([3, 4, 5].contains(frame)) {
          isAttackAvailable = true;
        }
      };
        animationTicker?.completed.then((_) {
            debugPrint('completed');
            isAttacking = false;
            isAttackAvailable = false;
            animationTicker?.reset();
            // current = GameCharacterStates.idle;
          
        });
    }

    // if (isDoubleAttack) {
    //   current = GameCharacterStates.attack2;
    //   await animationTicker?.completed;
    // }

    // current = GameCharacterStates.idle;
  }


  bool checkCollision(CollisionComponent component) {
    final componentX = component.position.x;
    final componentY = component.position.y;
    final componentWidth = component.width;
    final componentHeight = component.height;
    
    return (
      characterX < componentX + componentWidth &&
      characterX + movebox.width > componentX &&
      characterY - hitbox.y + movebox.y < componentY + componentHeight &&
      characterY - hitbox.y + movebox.y + movebox.height > componentY
    );
  }

  void setInvicible() {
    hitbox.collisionType = CollisionType.inactive;
    Future.delayed(Duration(milliseconds: getHitRefreshTime), () {
      hitbox.collisionType = CollisionType.active;
    });
  }

  void setFireEffect() {
    add(fireEffect);
    Future.delayed(const Duration(milliseconds: 500), () {
      fireEffect.removeFromParent();
    });
  }
}

enum GameCharacterStates {
  idle,
  run,
  attack1,
  attack2,
  attackTop1,
  attackTop2,
  attackBot1,
  attackBot2,
}
