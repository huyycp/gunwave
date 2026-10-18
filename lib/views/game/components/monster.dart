import 'dart:ui';
import 'dart:math' as math;

import 'package:gunwave/views/game/components/damage_number.dart';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:gunwave/data/constants/game/game_constants.dart';
import 'package:gunwave/data/models/monster_model.dart';
import 'package:gunwave/views/game/combat/combatant.dart';
import 'package:gunwave/views/game/combat/status_effect.dart';
import 'package:gunwave/views/game/components/sub_components/health_bar.dart';
import 'package:gunwave/views/game/components/sub_components/collision_grid.dart';
import 'package:gunwave/views/game/gunwave.dart';

class Monster extends SpriteAnimationGroupComponent
    with HasGameRef<Gunwave>, CollisionCallbacks
    implements Combatant {
  Monster({
    required this.monster,
    required super.position,
    required super.size,
    required this.negXBound,
    required this.posXBound,
  });

  final MonsterModel monster;
  CollisionGrid? collisionGrid;
  final double negXBound;
  final double posXBound;

  late final SpriteAnimation idleAni;
  late final SpriteAnimation runAni;
  late final SpriteAnimation attack1Ani;
  late final SpriteAnimation attack2Ani;
  late final SpriteAnimation attack3Ani;

  Vector2 velocity = Vector2.zero();

  int horizontalMovement = 1;

  double stepTime = 0.08;
  double moveSpeed = 120;
  int getHitRefreshTime = 500;

  late int hp = monster.hp;
  late int str = monster.str;
  late int vit = monster.vit;
  late int agi = monster.agi;
  @override
  final effects = StatusEffectController();
  @override
  int get health => hp;
  @override
  int get maxHealth => monster.hp;
  @override
  int get attackPower => str;
  @override
  bool get isAlive => !isDead;
  @override
  Vector2 get combatCenter =>
      Vector2(monsterX + hitbox.width / 2, monsterY + hitbox.height / 2);
  double _hurtCooldown = 0;
  double _attackCooldown = 0;

  /// Stun blocks contact damage; slow changes the interval between landed hits.
  bool get canDealContactDamage =>
      !isDead &&
      !effects.isStunned &&
      _attackCooldown <= 0 &&
      current == MonsterState.attack1;

  void onAttackLanded() => _attackCooldown =
      getHitRefreshTime / 1000 / effects.attackSpeedMultiplier;

  double accoumulatedTime = 0;

  /// The refresh time that monster can get hit from character

  late final double negXRange;
  late final double posXRange;

  final hitbox = RectangleHitbox(
    position: Vector2(64, 64),
    size: Vector2(64, 64),
  );

  late final attackbox = PolygonHitbox([
    Vector2(hitbox.x, 64 / 2),
    Vector2(hitbox.x + hitbox.width, 64 / 2),
    Vector2(hitbox.x + hitbox.width + 64 * 2 / 3, 64),
    Vector2(hitbox.x + hitbox.width + 64 * 4 / 5, 64 * 3 / 2),
    Vector2(hitbox.x + hitbox.width + 64 * 4 / 5, 64 * 2),
    Vector2(hitbox.x + hitbox.width, 64 * 2),
  ]);

  late final healthBar = HealthBar(
    maxHealth: maxHealth,
    currentHealth: hp,
    width: hitbox.width,
    position: Vector2(hitbox.x + hitbox.width / 2, hitbox.y - 10),
  );

  double get monsterX =>
      position.x + (scale.x > 0 ? hitbox.x : -hitbox.x - hitbox.width);
  double get monsterY => position.y + hitbox.y;
  bool get isDead => hp <= 0;

  @override
  Future<void> onLoad() async {
    onLoadAnimation();
    onLoadRange();

    add(hitbox);
    add(attackbox);

    add(healthBar);

    await super.onLoad();
  }

  @override
  void update(double dt) {
    accoumulatedTime += dt;
    while (accoumulatedTime > GameConstants.refreshRate) {
      effects.update(GameConstants.refreshRate);
      _hurtCooldown = math.max(0, _hurtCooldown - GameConstants.refreshRate);
      _attackCooldown = math.max(
        0,
        _attackCooldown - GameConstants.refreshRate,
      );
      super.update(GameConstants.refreshRate * effects.attackSpeedMultiplier);
      updateMovement(GameConstants.refreshRate);
      updateState();

      accoumulatedTime -= GameConstants.refreshRate;
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    // if (other is Character) {
    //   if (
    //     hitbox.collisionType == CollisionType.active &&
    //     other.isAttackAvailable &&
    //     hitbox.collidingWith(other.attackbox)
    //   ) {
    //     debugPrint("Monster is hit by character");
    //     setInvicible();
    //   }
    // }
    super.onCollision(intersectionPoints, other);
  }

  void onLoadAnimation() {
    idleAni = _createAnimation(frameAmount: 7, texturePosition: Vector2(0, 0));

    runAni = _createAnimation(frameAmount: 6, texturePosition: Vector2(0, 192));

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
    if (monster.monster == null) {
      throw Exception("Monster path is null");
    }
    return SpriteAnimation.fromFrameData(
      game.images.fromCache(monster.monster!.path),
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
    negXRange = position.x + hitbox.x - negXBound * GameConstants.tileSize;
    posXRange =
        position.x +
        hitbox.x +
        hitbox.width +
        posXBound * GameConstants.tileSize;
  }

  void updateMovement(double dt) {
    if (isDead || effects.isStunned) {
      velocity.setZero();
      return;
    }
    velocity.x = horizontalMovement * moveSpeed * effects.moveSpeedMultiplier;
    final startLeft = monsterX;
    final targetLeft = startLeft + velocity.x * dt;
    final left = startLeft < targetLeft ? startLeft : targetLeft;
    final right =
        (startLeft > targetLeft ? startLeft : targetLeft) + hitbox.width;
    final top = monsterY;
    final candidates = collisionGrid?.query(
      Rect.fromLTRB(left, top, right, top + hitbox.height),
    );
    final resolvedLeft = AabbMovement.resolveHorizontal(
      left: startLeft,
      top: top,
      width: hitbox.width,
      height: hitbox.height,
      delta: velocity.x * dt,
      obstacles:
          candidates?.map(
            (component) => Rect.fromLTWH(
              component.x,
              component.y,
              component.width,
              component.height,
            ),
          ) ??
          const <Rect>[],
    );
    position.x += resolvedLeft - startLeft;
    if (resolvedLeft != targetLeft) horizontalMovement = -horizontalMovement;
    if (monsterX < negXRange) {
      horizontalMovement = 1;
    } else if (monsterX > posXRange) {
      horizontalMovement = -1;
    }
    if (characterInRange()) {
      if (characterInAttackRange()) {
        horizontalMovement = 0;
      } else {
        horizontalMovement = 1;
      }
      if (game.character.characterX > monsterX + hitbox.width) {
        horizontalMovement = 1;
      } else if (game.character.characterX + hitbox.width < monsterX) {
        horizontalMovement = -1;
      }
    }
  }

  void updateState() {
    if (isDead) {
      removeFromParent();
      return;
    }
    if (effects.isStunned) {
      current = MonsterState.idle;
      return;
    }
    if (characterInAttackRange()) {
      if (current != MonsterState.attack1) {
        current = MonsterState.attack1;
      }
    } else if (horizontalMovement == 0) {
      current = MonsterState.idle;
    } else {
      if ((horizontalMovement > 0 && scale.x < 0) ||
          (horizontalMovement < 0 && scale.x > 0)) {
        flipHorizontallyAroundCenter();
      }
      current = MonsterState.run;
    }
  }

  void setInvincible() {
    _hurtCooldown = getHitRefreshTime / 1000;
  }

  @override
  bool takeDamage(Damage damage) {
    if (isDead || _hurtCooldown > 0) return false;
    final amount = effects.incomingDamage(damage.amount);
    if (amount <= 0) return false;
    final previous = hp;
    hp = (hp - amount).clamp(0, maxHealth);
    DamageNumber.show(parent, combatCenter, previous - hp, player: false);
    healthBar.updateHealth(hp);
    setInvincible();
    return true;
  }

  @override
  void heal(int amount) {
    if (isDead || amount <= 0) return;
    hp = (hp + amount).clamp(0, maxHealth);
    healthBar.updateHealth(hp);
  }

  @override
  void onRemove() {
    effects.clear();
    super.onRemove();
  }

  bool characterInRange() {
    bool isInXRange = game.character.scale.x > 0
        ? ((game.character.characterX + game.character.hitbox.width >=
                      negXRange &&
                  game.character.characterX + game.character.hitbox.width <=
                      posXRange) ||
              (game.character.characterX <= posXRange &&
                  game.character.characterX >= negXRange))
        : ((game.character.characterX >= negXRange &&
                  game.character.characterX <= posXRange) ||
              (game.character.characterX - game.character.hitbox.width <=
                      posXRange &&
                  game.character.characterX - game.character.hitbox.width >=
                      negXRange));
    bool isInYRange =
        ((game.character.characterY + game.character.hitbox.height >=
                monsterY &&
            game.character.characterY + game.character.hitbox.height <=
                monsterY + hitbox.height) ||
        (game.character.characterY <= monsterY + hitbox.height &&
            game.character.characterY >= monsterY));
    return !game.character.isDead && isInXRange && isInYRange;
  }

  bool characterInAttackRange() {
    bool isInXRange =
        ((scale.x < 0 &&
            game.character.characterX + game.character.hitbox.width * 2 / 3 >=
                x - attackbox.x - attackbox.width &&
            game.character.characterX <= x - attackbox.x - attackbox.width) ||
        (scale.x > 0 &&
            game.character.characterX + game.character.hitbox.width * 1 / 3 <=
                x + attackbox.x + attackbox.width &&
            game.character.characterX + game.character.hitbox.width >=
                x + attackbox.x + attackbox.width));
    bool isInYRange =
        ((game.character.characterY + game.character.hitbox.height >=
                y + attackbox.y &&
            game.character.characterY + game.character.hitbox.height <=
                y + attackbox.y + attackbox.height) ||
        (game.character.characterY <= y + attackbox.y + attackbox.height &&
            game.character.characterY >= y + attackbox.y));
    return characterInRange() && isInXRange && isInYRange;
  }
}

enum MonsterState { idle, run, attack1, attack2, attack3 }
