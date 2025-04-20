import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:gunwave/utils/extensions/string_ex.dart';
import 'package:gunwave/views/game/components/collision_component.dart';
import 'package:gunwave/views/game/components/component_hitbox.dart';
import 'package:gunwave/views/game/components/fruit_component.dart';
import 'package:gunwave/views/game/components/saw_component.dart';
import 'package:gunwave/views/game/pixel_adventure.dart';

class Character extends SpriteAnimationGroupComponent with HasGameRef<PixelAdventure>, KeyboardHandler, CollisionCallbacks {
  
  Character(this.character);

  final GameCharacters character;
  
  final double stepTime = 0.05;
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runAnimation;
  late final SpriteAnimation jumpAnimation;
  late final SpriteAnimation fallAnimation;
  late final SpriteAnimation hitAnimation;
  List<CollisionComponent> collisionComponents = [];
  final spawnPosition = Vector2.zero();

  double moveSpeed = 100;
  Vector2 velocity = Vector2.zero();

  /// Value : -1, 0, 1
  /// -1 = left, 0 = none, 1 = right
  int horizontalMovement = 0;

  final double gravity = 9.8;
  final double jumpSpeed = 300;
  final double terminalVelocity = 1000;
  bool isOnGround = true;
  bool hasJumped = false;
  final ComponentHitbox hitbox = const ComponentHitbox(
    offsetX: 2,
    offsetY: 2,
    width: 24,
    height: 24,
  );

  Map<String, int> collectedFruits = {};

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
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final isLeftKeyPressed = 
      keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
      keysPressed.contains(LogicalKeyboardKey.keyA);
    final isRightKeyPressed =
      keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
      keysPressed.contains(LogicalKeyboardKey.keyD);

    if (isLeftKeyPressed && isRightKeyPressed) {
      horizontalMovement = 0;
    } else if (isLeftKeyPressed) {
      horizontalMovement = -1;
    } else if (isRightKeyPressed) {
      horizontalMovement = 1;
    } else {
      horizontalMovement = 0;
    }

    hasJumped = 
      keysPressed.contains(LogicalKeyboardKey.space) ||
      keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
      keysPressed.contains(LogicalKeyboardKey.keyW);

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is FruitComponent) {
      collectedFruits[other.fruit] = (collectedFruits[other.fruit] ?? 0) + 1;
    }
    if (other is SawComponent) {
      velocity = Vector2.zero();
      horizontalMovement = 0;
      current = GameCharacterStates.hit;
      Future.delayed(const Duration(milliseconds: 150), () {
        position.x = spawnPosition.x;
        position.y = spawnPosition.y;
        current = GameCharacterStates.idle;
      });
    }
    super.onCollision(intersectionPoints, other);
  }

  void onLoadAnimation() {
    idleAnimation = _createAnimation(GameCharacterStates.idle, frameAmount: 11);
    runAnimation = _createAnimation(GameCharacterStates.run, frameAmount: 12);
    jumpAnimation = _createAnimation(GameCharacterStates.jump, frameAmount: 1);
    fallAnimation = _createAnimation(GameCharacterStates.fall, frameAmount: 1);
    hitAnimation = _createAnimation(GameCharacterStates.hit, frameAmount: 7);

    animations = {
      GameCharacterStates.idle: idleAnimation,
      GameCharacterStates.run: runAnimation,
      GameCharacterStates.jump: jumpAnimation,
      GameCharacterStates.fall: fallAnimation,
      GameCharacterStates.hit: hitAnimation,
    };

    current = GameCharacterStates.idle;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _updateCharacterMovement(dt);
    _updateCharacterState(dt);

    //// This order matters
    _updateCharacterHorizontalCollision();
    _addGravity(dt);
    _updateCharacterVerticalCollision();
    ////
  }

  SpriteAnimation _createAnimation(GameCharacterStates state, {required int frameAmount}) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('${character.path}/${state.getPath()}'),
      SpriteAnimationData.sequenced(
        amount: frameAmount,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );
  }

  void _updateCharacterState(double dt) {
    if (velocity.x == 0) {
      current = GameCharacterStates.idle;
    } else {
      final isMovingLeft = velocity.x <  0;
      if (
        (isMovingLeft && scale.x > 0) || 
        (!isMovingLeft && scale.x < 0)
      ) {
        flipHorizontallyAroundCenter();
      }
      current = GameCharacterStates.run;
    }

    if (velocity.y < 0) {
      current = GameCharacterStates.jump;
    } else if (velocity.y > 0) {
      current = GameCharacterStates.fall;
    }
  }

  void _updateCharacterMovement(double dt) {
    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;

    if (hasJumped && isOnGround) {
      velocity.y = -jumpSpeed;
      position.y += velocity.y * dt;
      hasJumped = false;
      isOnGround = false;
    }
  }

  void _updateCharacterHorizontalCollision() {
    for (var component in collisionComponents) {
      if (!component.isPlatform && checkCollision(component)) {
        if (horizontalMovement > 0) {
          position.x = component.x - width;
        } else if (horizontalMovement < 0) {
          position.x = component.x + component.width + width;
        }
      }
    }
  }

  void _updateCharacterVerticalCollision() {
    for (var component in collisionComponents) {
      if (component.isPlatform) {
        if (checkCollision(component)) {
          if (velocity.y > 0) {
            position.y = component.y - height;
            velocity.y = 0;
            isOnGround = true;
            hasJumped = false;
          }
        }
      } else {
        if (checkCollision(component)) {
          if (velocity.y > 0) {
            position.y = component.y - height;
            velocity.y = 0;
            isOnGround = true;
            hasJumped = false;
          } else if (velocity.y < 0) {
            position.y = component.y + component.height;
            velocity.y = 0;
          }
        }
      }
    }
  }

  bool checkCollision(CollisionComponent component) {
    final componentX = component.position.x;
    final componentY = component.position.y;
    final componentWidth = component.width;
    final componentHeight = component.height;

    final characterX = scale.x > 0 ? position.x : position.x - width;
    final characterY = component.isPlatform ? position.y + height : position.y;
    
    return (
      characterX < componentX + componentWidth &&
      characterX + width > componentX &&
      characterY < componentY + componentHeight &&
      position.y + height > componentY
    );
  }

  void _addGravity(double dt) {
    velocity.y += gravity;
    velocity.y = velocity.y.clamp(-jumpSpeed, terminalVelocity);
    position.y += velocity.y * dt;
  }
}

enum GameCharacters {
  maskDude('mask_dude'),
  ninjaFrog('ninja_frog'),
  pinkMan('pink_man'),
  virtualGuy('virtual_guy');

  const GameCharacters(this.character);
  final String character;

  static const String basePath = 'main_characters';

  String get path => '$basePath/$character';
}

enum GameCharacterStates {
  doubleJump,
  fall,
  hit,
  idle,
  jump,
  run,
  wallJump;

  String getPath({int size = 32}) => '${name.toReadable}_${size}x$size.png';
}
