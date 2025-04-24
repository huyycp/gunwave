import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/constants/game_constants.dart';
import 'package:gunwave/views/game/components/character.dart';
import 'package:gunwave/views/game/components/level.dart';
import 'package:gunwave/views/game/components/shoot_button.dart';
import 'package:gunwave/views/game/game_view_model.dart';

class PixelAdventure extends FlameGame with HasKeyboardHandlerComponents, DragCallbacks, HasCollisionDetection {
  PixelAdventure(this.ref, {this.joystickEnabled = false});
  final bool joystickEnabled;
  late final Character character;
  WidgetRef ref;
  late final JoystickComponent joystick;
  final bool isJoystickEnabled = false;
  String? gesture;
  Level? level;

  double accoumulatedTime = 0;

  @override
  Future<void> onLoad() async {
    character = Character(GameCharacters.virtualGuy);
    level = Level(character: character);
    if (level != null) world = level!;
    camera = CameraComponent.withFixedResolution(
      width: size.x,
      height: size.y,
      world: world,
    );

    camera.viewfinder.anchor = Anchor.bottomLeft;
    camera.viewfinder.position = Vector2(0, level?.world.height ?? 0);

    await images.loadAllImages();

    addAll([
      world,
      camera,
    ]);


    if (joystickEnabled) {
      addJoystick();
    }


    camera.viewport.add(ShootButton(
      position: Vector2(size.x - 150, size.y - 120),
      size: Vector2(64, 64),
      onShoot: () {
        level?.shoot();
      }
    ));

    return super.onLoad();
  } 

  @override
  void update(double dt) {
    accoumulatedTime += dt;
    while (accoumulatedTime > GameConstants.refreshRate) {
      gesture = ref.read(gameViewModel).gesture;
      if (gesture != null) {
        switch (gesture) {
          case 'Victory':
            character.hasJumped = true;
            break;
          case 'Closed_Fist':
            character.horizontalMovement = 0;
            break;
          case 'Thumb_Up':
            character.horizontalMovement = -1;
            break;
          case 'Thumb_Down':
            character.horizontalMovement = 1;
            break;
          case "Pointing_Up":
            level?.shoot();
            break;
          default:
            // character.horizontalMovement = 0;
            break;
        }
        // debugPrint('horizontalMovement: ${character.horizontalMovement}');
        // debugPrint('velocity: ${character.velocity}');
      }
      if (joystickEnabled) updateJoystick();
      
      accoumulatedTime -= GameConstants.refreshRate;
      super.update(GameConstants.refreshRate);
    }
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