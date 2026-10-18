import 'dart:async';
import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:gunwave/views/game/components/damage_number.dart';
import 'package:gunwave/data/constants/game/game_constants.dart';
import 'package:gunwave/data/constants/game/game_effect.dart';
import 'package:gunwave/data/models/character_model.dart';
import 'package:gunwave/views/game/combat/combatant.dart';
import 'package:gunwave/views/game/combat/status_effect.dart';
import 'package:gunwave/views/game/components/sub_components/building.dart';
import 'package:gunwave/views/game/components/sub_components/collision_component.dart';
import 'package:gunwave/views/game/components/sub_components/collision_grid.dart';
import 'package:gunwave/views/game/components/monster.dart';
import 'package:gunwave/views/game/components/sub_components/trap.dart';
import 'package:gunwave/views/game/gunwave.dart';

class Character extends SpriteAnimationGroupComponent
    with HasGameRef<Gunwave>, KeyboardHandler, CollisionCallbacks
    implements Combatant {
  Character(this.character, {this.onCharacterReachCheckpoint});

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

  /// One source of truth shared by combat and the fixed screen HUD.
  late final healthNotifier = ValueNotifier<int>(character.hp);
  int get hp => healthNotifier.value;
  set hp(int value) => healthNotifier.value = value;
  late int str = character.str;
  late int vit = character.vit;
  late int agi = character.agi;
  late int moveSpeed = agi;
  @override
  final effects = StatusEffectController();
  @override
  int get health => hp;
  @override
  int get maxHealth => character.hp;
  @override
  int get attackPower => str;
  @override
  bool get isAlive => !isDead;
  @override
  Vector2 get combatCenter =>
      Vector2(characterX + hitbox.width / 2, characterY + hitbox.height / 2);

  final facingDirection = Vector2(1, 0);
  Vector2 _dashDirection = Vector2.zero();
  double _dashRemaining = 0;
  double _dashSpeed = 0;
  double _hurtCooldown = 0;
  double _fireRemaining = 0;
  int _swingDamage = 0;
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

  late final attackbox = PolygonHitbox([
    Vector2(hitbox.x + hitbox.width, 64 / 3),
    Vector2(64 + 64 + 64 * 2 / 3, 64),
    Vector2(64 + 64 + 64 * 4 / 5, 64 * 3 / 2),
    Vector2(64 + 64 + 64 * 4 / 5, 64 * 2),
    Vector2(hitbox.x + hitbox.width, 64 * 2),
  ]);

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
      hitbox.x + hitbox.width / 2 - 24,
      hitbox.y,
    ), // Position above head
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

    priority = 5;

    return super.onLoad();
  }

  @override
  void update(double dt) {
    accoumulatedTime += dt;
    while (accoumulatedTime > GameConstants.refreshRate) {
      effects.update(GameConstants.refreshRate);
      _hurtCooldown = math.max(0, _hurtCooldown - GameConstants.refreshRate);
      if (_fireRemaining > 0) {
        _fireRemaining -= GameConstants.refreshRate;
        if (_fireRemaining <= 0) fireEffect.removeFromParent();
      }
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
    // Handle Escape here: Flame consumes handled keys before Flutter shortcuts.
    if (game.playMode.isKeyboard &&
        event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      game.onExitRequested?.call();
      return true;
    }
    if (!game.playMode.isKeyboard || game.controlsBlocked) {
      horizontalMovement = verticalMovement = 0;
      triggerAttack = false;
      return true;
    }
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.keyK) {
      game.activateAbility();
    }
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

    // Key-repeat events must keep a held attack active until J is released.
    triggerAttack = keysPressed.contains(LogicalKeyboardKey.keyJ);
    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
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
        other.takeDamage(Damage(_swingDamage, source: DamageSource.melee));
        // debugPrint('Monster HP: ${other.hp}');
      }

      if (other.canDealContactDamage && !isDead) {
        if (takeDamage(Damage(other.str, source: DamageSource.monster))) {
          other.onAttackLanded();
        }
        // debugPrint('Character HP: $hp');
      }
    }
    if (other is Trap) {
      if (other.trap == GameEffects.fire) {
        if (other.hitbox.collidingWith(hitbox) &&
            hitbox.collisionType == CollisionType.active &&
            !isDead) {
          if (takeDamage(Damage(other.damage, source: DamageSource.fire))) {
            setFireEffect();
          }
          // debugPrint('Character HP: $hp');
        }
      }
    }
    super.onCollision(intersectionPoints, other);
  }

  void onLoadAnimation() {
    idleAni = _createAnimation(
      frameAmount: 6,
      loop: true,
      texturePosition: Vector2(0, 0),
    );
    runAni = _createAnimation(
      frameAmount: 6,
      loop: true,
      texturePosition: Vector2(0, 192),
    );
    attach1Ani = _createAnimation(
      frameAmount: 6,
      loop: false,
      texturePosition: Vector2(0, 192 * 2),
    );
    attach2Ani = _createAnimation(
      frameAmount: 6,
      loop: false,
      texturePosition: Vector2(0, 192 * 3),
    );
    attachTop1Ani = _createAnimation(
      frameAmount: 6,
      loop: false,
      texturePosition: Vector2(0, 192 * 4),
    );
    attachTop2Ani = _createAnimation(
      frameAmount: 6,
      loop: false,
      texturePosition: Vector2(0, 192 * 5),
    );
    attachBot1Ani = _createAnimation(
      frameAmount: 6,
      loop: false,
      texturePosition: Vector2(0, 192 * 6),
    );
    attachBot2Ani = _createAnimation(
      frameAmount: 6,
      loop: false,
      texturePosition: Vector2(0, 192 * 7),
    );

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
    final dashing = _dashRemaining > 0;
    if (dashing) {
      dt = math.min(dt, _dashRemaining);
      _dashRemaining = math.max(0, _dashRemaining - dt);
      velocity.setFrom(_dashDirection * _dashSpeed);
    } else {
      velocity.x = horizontalMovement * moveSpeed * effects.moveSpeedMultiplier;
      velocity.y = verticalMovement * moveSpeed * effects.moveSpeedMultiplier;
      if (velocity.length2 > 0) facingDirection.setFrom(velocity.normalized());
    }
    final grid = collisionGrid;
    if (grid == null) {
      position += velocity * dt;
      if (dashing && _dashRemaining <= 0) effects.remove('quickstep');
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
    if (dashing &&
        (_dashRemaining <= 0 ||
            resolvedLeft != targetLeft ||
            resolvedTop != targetTop)) {
      _dashRemaining = 0;
      effects.remove('quickstep');
    }
  }

  Rect _collisionRect(CollisionComponent component) => Rect.fromLTWH(
    component.x,
    component.y,
    component.width,
    component.height,
  );

  void attack({bool isDouble = false}) {
    if (isDead || effects.isStunned) return;
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
      _swingDamage = (str * effects.consumeAttackMultiplier()).round();
      current = GameCharacterStates.attack1;
      animationTicker?.onFrame = (frame) {
        if ([3, 4, 5].contains(frame)) {
          isAttackAvailable = true;
        }
      };
      animationTicker?.completed.then((_) {
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
    _hurtCooldown = getHitRefreshTime / 1000;
  }

  void setFireEffect() {
    _fireRemaining = getHitRefreshTime / 1000;
    if (!fireEffect.isMounted && fireEffect.parent == null) add(fireEffect);
  }

  /// Resolves fire and combat damage while keeping checkpoint hitboxes active.
  @override
  bool takeDamage(Damage damage) {
    if (isDead || _hurtCooldown > 0) return false;
    final amount = effects.incomingDamage(damage.amount);
    if (amount <= 0) return false;
    final previous = hp;
    hp = (hp - amount).clamp(0, maxHealth);
    DamageNumber.show(parent, combatCenter, previous - hp, player: true);
    setInvicible();
    return true;
  }

  @override
  void heal(int amount) {
    if (isDead || amount <= 0) return;
    hp = (hp + amount).clamp(0, maxHealth);
  }

  /// Moves in the last facing direction through the normal swept wall resolver.
  bool startDash({required double distance, required double duration}) {
    if (isDead || _dashRemaining > 0 || distance <= 0 || duration <= 0) {
      return false;
    }
    _dashDirection = facingDirection.clone();
    _dashRemaining = duration;
    _dashSpeed = distance / duration;
    effects.add(
      StatusEffect(key: 'quickstep', duration: duration, invulnerable: true),
    );
    return true;
  }

  @override
  void onRemove() {
    effects.clear();
    _dashRemaining = 0;
    super.onRemove();
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
