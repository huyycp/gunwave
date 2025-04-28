import 'dart:async';
import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:gunwave/data/constants/game/game_character.dart';
import 'package:gunwave/data/constants/game/game_constants.dart';
import 'package:gunwave/utils/app_math.dart';
import 'package:gunwave/utils/extensions/string_ex.dart';
import 'package:gunwave/views/game/components/collision_component.dart';
import 'package:gunwave/views/game/components/component_hitbox.dart';
import 'package:gunwave/views/game/gunwave.dart';

class Character extends SpriteAnimationGroupComponent with HasGameRef<Gunwave>, KeyboardHandler, CollisionCallbacks {
  
  Character(this.character);

  final GameCharacter character;
  
  final double stepTime = 0.08;
  late final SpriteAnimation idleAni;
  late final SpriteAnimation runAni;
  late final SpriteAnimation attachRightAni;
  late final SpriteAnimation attachTopAni;
  late final SpriteAnimation attachBotAni;
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

  final double gravity = 9.8;
  final double jumpSpeed = 300;
  final double terminalVelocity = 1000;
  bool isOnGround = true;
  bool hasJumped = false;

  bool isDying = false;

  final ComponentHitbox hitbox = const ComponentHitbox(
    offsetX: 64,
    offsetY: 64,
    width: 64,
    height: 64,
  );

  Map<String, int> collectedFruits = {};

  double accoumulatedTime = 0;

  double get characterX => scale.x > 0 ? position.x + hitbox.offsetX : position.x - hitbox.offsetX - hitbox.width;
  double get characterY => position.y + hitbox.offsetY;

  @override
  FutureOr<void> onLoad() {
    onLoadAnimation();

    spawnPosition.x = position.x;
    spawnPosition.y = position.y;

    add(
      RectangleHitbox(
        size: Vector2(hitbox.width, hitbox.height),
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
      ),
    );
    return super.onLoad();
  }

  @override
  void update(double dt) {
    accoumulatedTime += dt;
    while (accoumulatedTime > GameConstants.refreshRate) {
      super.update(GameConstants.refreshRate);
      _updateCharacterMovement(GameConstants.refreshRate);
      _updateCharacterState(GameConstants.refreshRate);
      _updateCharacterCollision();
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

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    // if (other is FruitComponent) {
    //   collectedFruits[other.fruit] = (collectedFruits[other.fruit] ?? 0) + 1;
    // }
    // if (other is SawComponent) {
    //   velocity = Vector2.zero();
    //   horizontalMovement = 0;
    //   current = GameCharacterStates.hit;
    //   isDying = true;
    //   Future.delayed(const Duration(milliseconds: 150), () {
    //     position.x = spawnPosition.x;
    //     position.y = spawnPosition.y;
    //     current = GameCharacterStates.idle;
    //     isDying = false;
    //   });
    // }

    super.onCollision(intersectionPoints, other);
  }

  void onLoadAnimation() {
    idleAni = _createAnimation(frameAmount: 6, texturePosition: Vector2(0, 0));
    runAni = _createAnimation(frameAmount: 6, texturePosition: Vector2(0, 192));
    attachRightAni = _createAnimation(frameAmount: 12, framePerRow: 6, texturePosition: Vector2(0, 192 * 2));
    attachTopAni = _createAnimation(frameAmount: 12, framePerRow: 6, texturePosition: Vector2(0, 192 * 4));
    attachBotAni = _createAnimation(frameAmount: 12, framePerRow: 6, texturePosition: Vector2(0, 192 * 6));

    animations = {
      GameCharacterStates.idle: idleAni,
      GameCharacterStates.run: runAni,
      GameCharacterStates.attachRight: attachRightAni,
      GameCharacterStates.attachTop: attachTopAni,
      GameCharacterStates.attachBottom: attachBotAni,
    };

    current = GameCharacterStates.attachRight;
  }

  SpriteAnimation _createAnimation({
    required int frameAmount,
    required Vector2 texturePosition,
    int? framePerRow,
  }) {
  
    return SpriteAnimation.fromFrameData(
      game.images.fromCache(character.path),
      SpriteAnimationData.sequenced(
        amount: frameAmount,
        amountPerRow: framePerRow,
        stepTime: stepTime,
        textureSize: Vector2(192, 192),
        texturePosition: texturePosition,
      ),
    );
  }

  void _updateCharacterState(double dt) {
    if (velocity.x == 0 && velocity.y == 0) {
      current = GameCharacterStates.idle;
    } else {
      final isMovingLeft = velocity.x < 0;
      final isMovingRight = velocity.x > 0;
      if (
        (isMovingLeft && scale.x > 0) || 
        (isMovingRight && scale.x < 0)
      ) {
        flipHorizontallyAroundCenter();
      }
      current = GameCharacterStates.run;
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

        final aPoint = Vector2(component.x - hitbox.width, component.y - hitbox.height);
        final bPoint = Vector2(component.x + component.width, component.y - hitbox.height);
        final cPoint = Vector2(component.x + component.width, component.y + component.height);
        final dPoint = Vector2(component.x - hitbox.width, component.y + component.height);
        
        double angCB = calculateAngle(cPoint, component.position, bPoint);
        double angCA = calculateAngle(cPoint, component.position, aPoint);
        double angCD = calculateAngle(cPoint, component.position, dPoint);

        if (angCB < 0) angCB += 2 * pi;
        if (angCA < 0) angCA += 2 * pi;
        if (angCD < 0) angCD += 2 * pi;

        double angCChar = calculateAngle(cPoint, component.position, Vector2(characterX, characterY));
        if (angCChar < 0) angCChar += 2 * pi;

        if (angCChar > 0 && angCChar < angCB) {
          // right
          debugPrint("right");
          position.x = scale.x > 0 
            ? component.x + component.width - hitbox.offsetX
            : component.x + component.width + hitbox.width + hitbox.offsetX;
        } else if (angCChar > angCB && angCChar < angCA) {
          // top
          debugPrint("top");
          position.y = component.y - hitbox.height - hitbox.offsetY;
        } else if (angCChar > angCA && angCChar < angCD) {
          // left
          debugPrint("left");
          position.x = scale.x > 0
            ? component.x - hitbox.width - hitbox.offsetX
            : component.x + hitbox.offsetX;
        } else if (angCChar > angCD && angCChar < 2 * pi) {
          // bottom
          debugPrint("bottom");
          position.y = component.y + component.height - hitbox.offsetY;
        }
      }
    }
  }

  bool checkCollision(CollisionComponent component) {
    final componentX = component.position.x;
    final componentY = component.position.y;
    final componentWidth = component.width;
    final componentHeight = component.height;
    
    return (
      characterX < componentX + componentWidth &&
      characterX + hitbox.width > componentX &&
      characterY < componentY + componentHeight &&
      characterY + hitbox.height > componentY
    );
  }
}

enum GameCharacterStates {
  idle,
  run,
  attachRight,
  attachTop,
  attachBottom;
}
