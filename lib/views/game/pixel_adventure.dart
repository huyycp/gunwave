import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:gunwave/data/constants/game_constants.dart';
import 'package:gunwave/views/game/components/character.dart';
import 'package:gunwave/views/game/components/level.dart';
import 'package:gunwave/views/game/components/shoot_button.dart';

class PixelAdventure extends FlameGame with HasKeyboardHandlerComponents, DragCallbacks, HasCollisionDetection {
  late final Character character;
  late final JoystickComponent joystick;
  final bool isJoystickEnabled = true;

  @override
  Future<void> onLoad() async {
    character = Character(GameCharacters.virtualGuy);
    final level = Level(character: character);
    world = level;
    camera = CameraComponent.withFixedResolution(
      width: size.x,
      height: size.y,
      world: world,
    );

    camera.viewfinder.anchor = Anchor.bottomLeft;
    camera.viewfinder.position = Vector2(0, level.world.height);

    await images.loadAllImages();

    addAll([
      world,
      camera,
    ]);


    if (isJoystickEnabled) {
      addJoystick();
    }

    camera.viewport.add(ShootButton(
      position: Vector2(size.x - 150, size.y - 120),
      size: Vector2(64, 64),
      onShoot: () {
        level.shoot();
      }
    ));

    return super.onLoad();
  } 

  @override
  void update(double dt) {
    if (isJoystickEnabled) updateJoystick();
    super.update(dt);
  }

  void addJoystick() {
    joystick = JoystickComponent(
      knob: SpriteComponent(
        sprite: Sprite(images.fromCache(GameComponents.joystickKnob.path)),
        size: Vector2.all(64),
      ),
      background: SpriteComponent(
        sprite: Sprite(images.fromCache(GameComponents.joystickBackground.path)),
        size: Vector2.all(128),
      ),
      margin: const EdgeInsets.only(left: 60, bottom: 40),
    );

    camera.viewport.add(joystick);
  }

  void updateJoystick() {
    switch(joystick.direction) {
      case JoystickDirection.upLeft:
        character.hasJumped = true;
        character.horizontalMovement = -1;
        break;
      case JoystickDirection.left:
      case JoystickDirection.downLeft:
        character.horizontalMovement = -1;
        break;
      case JoystickDirection.upRight:
        character.hasJumped = true;
        character.horizontalMovement = 1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.downRight:
        character.horizontalMovement = 1;
        break;
      case JoystickDirection.up:
        character.hasJumped = true;
        break;
      default:
        if (!character.hasJumped) {
          character.horizontalMovement = 0;
        }
    }
  }
}