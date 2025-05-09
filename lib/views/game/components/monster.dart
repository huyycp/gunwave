import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:gunwave/data/constants/game/game_constants.dart';
import 'package:gunwave/data/constants/game/game_monster.dart';
import 'package:gunwave/views/game/components/sub_components/health_bar.dart';
import 'package:gunwave/views/game/gunwave.dart';

class Monster extends SpriteAnimationGroupComponent with HasGameRef<Gunwave>, CollisionCallbacks {
  Monster({
    required this.monster,
    required super.position,
    required super.size,
    required this.negXBound,
    required this.posXBound,
  });

  final GameMonsters monster;
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

  int hp = 100;
  int str = 40;

  double accoumulatedTime = 0;

  /// The refresh time that monster can get hit from character

  late final double negXRange;
  late final double posXRange;


  final hitbox = RectangleHitbox(
    position: Vector2(64, 64),
    size: Vector2(64, 64),
  );

  late final attackbox = PolygonHitbox(
    [
      Vector2(hitbox.x, 64 / 2),
      Vector2(hitbox.x + hitbox.width, 64 / 2),
      Vector2(hitbox.x + hitbox.width + 64 * 2 / 3, 64),
      Vector2(hitbox.x + hitbox.width + 64 * 4 / 5, 64 * 3 / 2),
      Vector2(hitbox.x + hitbox.width + 64 * 4 / 5, 64 * 2),
      Vector2(hitbox.x + hitbox.width, 64 * 2),
    ],
  );

  late final healthBar = HealthBar(
    maxHealth: hp,
    currentHealth: hp,
    width: hitbox.width,
    position: Vector2(hitbox.x + hitbox.width / 2, hitbox.y - 10),
  );

  double get monsterX => position.x + (scale.x > 0 ? hitbox.x : - hitbox.x - hitbox.width);
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

      super.update(GameConstants.refreshRate);
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
    negXRange = position.x + hitbox.x - negXBound * GameConstants.tileSize;
    posXRange = position.x + hitbox.x + hitbox.width + posXBound * GameConstants.tileSize;
  }

  void updateMovement(double dt) {
    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;
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
    if (isDead) removeFromParent();
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

  void setInvicible() {
    if (hitbox.collisionType == CollisionType.inactive) {
      return;
    }
    hitbox.collisionType = CollisionType.inactive;
    Future.delayed(Duration(milliseconds: getHitRefreshTime), () {
      hitbox.collisionType = CollisionType.active;
    });
  }

  bool characterInRange() {
    bool isInXRange = game.character.scale.x > 0
      ? ((
          game.character.characterX + game.character.hitbox.width >= negXRange && 
          game.character.characterX + game.character.hitbox.width <= posXRange
        ) || (
          game.character.characterX <= posXRange &&
          game.character.characterX >= negXRange
        ))
      : ((
          game.character.characterX >= negXRange && 
          game.character.characterX <= posXRange
        ) || (
          game.character.characterX - game.character.hitbox.width <= posXRange &&
          game.character.characterX - game.character.hitbox.width >= negXRange
        ));
    bool isInYRange = (
      (
        game.character.characterY + game.character.hitbox.height >= monsterY  &&
        game.character.characterY + game.character.hitbox.height <= monsterY + hitbox.height
      ) || (
        game.character.characterY <= monsterY + hitbox.height &&
        game.character.characterY >= monsterY
      )
    );
    return !game.character.isDead && isInXRange && isInYRange; 
  }

  bool characterInAttackRange() {
    
    bool isInXRange = (
      (
        scale.x < 0 && 
        game.character.characterX + game.character.hitbox.width * 2 / 3 >= x - attackbox.x - attackbox.width &&
        game.character.characterX <= x - attackbox.x - attackbox.width
      ) || (
        scale.x > 0 &&
        game.character.characterX + game.character.hitbox.width * 1 / 3 <= x + attackbox.x + attackbox.width &&
        game.character.characterX + game.character.hitbox.width >= x + attackbox.x + attackbox.width
      )
    );
    bool isInYRange = (
      (
        game.character.characterY + game.character.hitbox.height >= y + attackbox.y &&
        game.character.characterY + game.character.hitbox.height <= y + attackbox.y + attackbox.height
      ) || (
        game.character.characterY <= y + attackbox.y + attackbox.height &&
        game.character.characterY >= y + attackbox.y
      )
    );
    return characterInRange() && isInXRange && isInYRange;
  }
}

enum MonsterState {
  idle,
  run,
  attack1,
  attack2,
  attack3,
}

