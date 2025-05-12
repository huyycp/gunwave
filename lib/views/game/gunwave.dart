import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/constants/game/game_character.dart';
import 'package:gunwave/data/constants/game/game_constants.dart';
import 'package:gunwave/data/constants/game/game_hub.dart';
import 'package:gunwave/data/constants/game/game_map.dart';
import 'package:gunwave/data/models/map_model.dart';
import 'package:gunwave/views/game/components/character.dart';
import 'package:gunwave/views/game/components/stage.dart';
import 'package:gunwave/views/game/components/sub_components/attack_button.dart';

class Gunwave extends FlameGame with HasKeyboardHandlerComponents, DragCallbacks, HasCollisionDetection {
  Gunwave(
    this.ref, {
    required this.map,
    this.isJoystickEnabled = false,
    required this.onStageCompleted,
    required this.onStageFailed,
  });

  @override
  bool get pauseWhenBackgrounded => false;


  WidgetRef ref;
  MapModel map;
  final bool isJoystickEnabled;
  final void Function() onStageCompleted;
  final void Function() onStageFailed;
  
  late final JoystickComponent joystick;
  late final Character character;
  Stage? stage;

  double accoumulatedTime = 0;

  @override
  Future<void> onLoad() async {
    images.prefix = '';
    await images.loadAllImages();

    character = Character(GameCharacters.bluePawn);
    stage = Stage(
      world: map,
      character: character,
      onStageCompleted: onStageCompleted,
      onStageFailed: onStageFailed,
    );
    if (stage != null) world = stage!;
    camera = CameraComponent.withFixedResolution(
      width: size.x,
      height: size.y,
      world: world,
    );

    camera.viewfinder.anchor = Anchor.topLeft;

    if (isJoystickEnabled) {
      addJoystick();
      addAttachBtn();
    }

    return super.onLoad();
  }

  @override
  void update(double dt) {
    accoumulatedTime += dt;
    while (accoumulatedTime > GameConstants.refreshRate) {
      camera.viewfinder.position = Vector2(
        (character.scale.x > 0 ? character.x : character.x - character.width) - size.x / 4,
        (character.y - (size.y - character.height) / 2),
      );
      if (isJoystickEnabled) updateJoystick();

      accoumulatedTime -= GameConstants.refreshRate;
      super.update(GameConstants.refreshRate);
    }
  }

  void addJoystick() {
    joystick = JoystickComponent(
      knob: SpriteComponent(
        sprite: Sprite(images.fromCache(GameHubs.joystickKnob.path)),
        size: Vector2.all(64),
      ),
      background: SpriteComponent(
        sprite: Sprite(images.fromCache(GameHubs.joystickBackground.path)),
        size: Vector2.all(128),
      ),
      margin: const EdgeInsets.only(left: 60, bottom: 40),
    );

    camera.viewport.add(joystick);
  }

  void addAttachBtn() {
    final attachBtn = AttachButton(
      onAttack: (bool attack) {
        character.triggerAttack = attack;
      },
      position: Vector2(size.x - 100, size.y - 100),
      size: Vector2.all(64),
    );

    camera.viewport.add(attachBtn);
  }

  void updateJoystick() {
    switch(joystick.direction) {
      case JoystickDirection.upLeft:
        character.verticalMovement = -1;
        character.horizontalMovement = -1;
        break;
      case JoystickDirection.left:
        character.verticalMovement = 0;
        character.horizontalMovement = -1;
        break;
      case JoystickDirection.downLeft:
        character.verticalMovement = 1;
        character.horizontalMovement = -1;
        break;
      case JoystickDirection.upRight:
        character.verticalMovement = -1;
        character.horizontalMovement = 1;
        break;
      case JoystickDirection.right:
        character.verticalMovement = 0;
        character.horizontalMovement = 1;
        break;
      case JoystickDirection.downRight:
        character.verticalMovement = 1;
        character.horizontalMovement = 1;
        break;
      case JoystickDirection.up:
        character.verticalMovement = -1;
        character.horizontalMovement = 0;
        break;
      case JoystickDirection.down:
        character.verticalMovement = 1;
        character.horizontalMovement = 0;
        break;
      default:
        character.verticalMovement = 0;
        character.horizontalMovement = 0;
    }
  }
}