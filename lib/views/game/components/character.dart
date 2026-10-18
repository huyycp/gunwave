import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:gunwave/data/constants/game/game_constants.dart';
import 'package:gunwave/data/constants/game/game_effect.dart';
import 'package:gunwave/data/models/character_model.dart';
import 'package:gunwave/views/game/components/sub_components/building.dart';
import 'package:gunwave/views/game/components/sub_components/collision_component.dart';
import 'package:gunwave/views/game/components/sub_components/collision_grid.dart';
import 'package:gunwave/views/game/components/monster.dart';
import 'package:gunwave/views/game/components/sub_components/health_bar.dart';
import 'package:gunwave/views/game/components/sub_components/trap.dart';
import 'package:gunwave/views/game/gunwave.dart';

class Character extends SpriteAnimationGroupComponent
    with HasGameRef<Gunwave>, KeyboardHandler, CollisionCallbacks {
  Character(
    this.character, {
    this.onCharacterReachCheckpoint,
  });

  final CharacterModel character;
  final void Function(bool)? onCharacterReachCheckpoint;

  final double stepTime = 0.08;
  late final SpriteAnimation idleAni;
  late final SpriteAnimation runAni;
  late final SpriteAnimation attach1Ani;
  late final SpriteAnimation attach2Ani;
  late final SpriteAnimation attachTop1Ani;
  late final SpriteAnimation attachTop2Ani;
  late final SpriteAnimation attachBot1Ani;
  late final SpriteAnimation attachBot2Ani;
  CollisionGrid? collisionGrid;

  final spawnPosition = Vector2.zero();

  late int hp = character.hp;
  late int str = character.str;
  late int vit = character.vit;
  late int agi = character.agi;
  late int moveSpeed = agi;
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

  double get characterX => scale.x > 0
      ? position.x + hitbox.x
      : position.x - hitbox.x - hitbox.width;
  double get characterY => position.y + hitbox.y;

  bool get isDead => hp <= 0;

  int getHitRefreshTime = 500;

  late final healthBar = HealthBar(
    maxHealth: character.hp,
    currentHealth: hp,
    width: 60,
    position: Vector2(
        hitbox.x + hitbox.width / 2, hitbox.y - 20), // Position above head
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
    position: Vector2(
        hitbox.x + hitbox.width / 2 - 24, hitbox.y), // Position above head
  );

  // Create a set to track which checkpoints we're currently in
  final Set<Building> _activeCheckpoints = {};

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
    final isUpKeyPressed = keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
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
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Building && other.isCheckpoint) {
      if (movebox.collidingWith(other.checkZone)) {
        _activeCheckpoints.add(other);
        if (onCharacterReachCheckpoint != null) {
          onCharacterReachCheckpoint!(true);
        }
      }
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (other is Building &&
        other.isCheckpoint &&
        _activeCheckpoints.contains(other)) {
      // Remove from tracked checkpoints
      _activeCheckpoints.remove(other);

      // Call the callback without checking collision status again
      if (onCharacterReachCheckpoint != null) {
        onCharacterReachCheckpoint!(false);
      }
    }
    super.onCollisionEnd(other);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Monster) {
      if (isAttackAvailable &&
          other.hitbox.collisionType == CollisionType.active &&
          attackbox.collidingWith(other.hitbox) &&
          !other.isDead) {
        other.hp -= str;
        other.healthBar.updateHealth(other.hp);
        other.setInvincible();
        // debugPrint('Monster HP: ${other.hp}');
      }

      if (other.current == MonsterState.attack1 &&
              hitbox.collisionType == CollisionType.active &&
              !isDead
          // other.attackbox.collidingWith(hitbox)
          ) {
        hp -= other.str;
        healthBar.updateHealth(hp);
        setInvicible();
        // debugPrint('Character HP: $hp');
      }
    }
    if (other is Trap) {
      if (other.trap == GameEffects.fire) {
        if (other.hitbox.collidingWith(hitbox) &&
            hitbox.collisionType == CollisionType.active &&
            !isDead) {
          hp -= other.damage;
          healthBar.updateHealth(hp);
          setInvicible();
          setFireEffect();
          // debugPrint('Character HP: $hp');
        }
      }
    }
    super.onCollision(intersectionPoints, other);
  }

  void onLoadAnimation() {
    idleAni = _createAnimation(
        frameAmount: 6, loop: true, texturePosition: Vector2(0, 0));
    runAni = _createAnimation(
        frameAmount: 6, loop: true, texturePosition: Vector2(0, 192));
    attach1Ani = _createAnimation(
        frameAmount: 6, loop: false, texturePosition: Vector2(0, 192 * 2));
    attach2Ani = _createAnimation(
        frameAmount: 6, loop: false, texturePosition: Vector2(0, 192 * 3));
    attachTop1Ani = _createAnimation(
        frameAmount: 6, loop: false, texturePosition: Vector2(0, 192 * 4));
    attachTop2Ani = _createAnimation(
        frameAmount: 6, loop: false, texturePosition: Vector2(0, 192 * 5));
    attachBot1Ani = _createAnimation(
        frameAmount: 6, loop: false, texturePosition: Vector2(0, 192 * 6));
    attachBot2Ani = _createAnimation(
        frameAmount: 6, loop: false, texturePosition: Vector2(0, 192 * 7));

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
      game.images.fromCache(character.character!.path),
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
      if ((isMovingLeft && scale.x > 0) || (isMovingRight && scale.x < 0)) {
        flipHorizontallyAroundCenter();
      }
      if (!isAttacking) current = GameCharacterStates.run;
    }
  }

  void _updateCharacterMovement(double dt) {
    velocity.x = horizontalMovement * moveSpeed * 1.0;
    velocity.y = verticalMovement * moveSpeed * 1.0;
    final grid = collisionGrid;
    if (grid == null) {
      position += velocity * dt;
      return;
    }

    final bodyLeft = characterX;
    final bodyTop = position.y + movebox.y;
    final targetLeft = bodyLeft + velocity.x * dt;
    final horizontalBounds = Rect.fromLTRB(
      bodyLeft < targetLeft ? bodyLeft : targetLeft,
      bodyTop,
      (bodyLeft > targetLeft ? bodyLeft : targetLeft) + movebox.width,
      bodyTop + movebox.height,
    );
    final resolvedLeft = AabbMovement.resolveHorizontal(
      left: bodyLeft,
      top: bodyTop,
      width: movebox.width,
      height: movebox.height,
      delta: velocity.x * dt,
      obstacles: grid.query(horizontalBounds).map(_collisionRect),
    );
    position.x += resolvedLeft - bodyLeft;
    if (resolvedLeft != targetLeft) velocity.x = 0;

    final targetTop = bodyTop + velocity.y * dt;
    final verticalBounds = Rect.fromLTRB(
      resolvedLeft,
      bodyTop < targetTop ? bodyTop : targetTop,
      resolvedLeft + movebox.width,
      (bodyTop > targetTop ? bodyTop : targetTop) + movebox.height,
    );
    final resolvedTop = AabbMovement.resolveVertical(
      left: resolvedLeft,
      top: bodyTop,
      width: movebox.width,
      height: movebox.height,
      delta: velocity.y * dt,
      obstacles: grid.query(verticalBounds).map(_collisionRect),
    );
    position.y += resolvedTop - bodyTop;
    if (resolvedTop != targetTop) velocity.y = 0;
  }

  Rect _collisionRect(CollisionComponent component) => Rect.fromLTWH(
      component.x, component.y, component.width, component.height);

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
