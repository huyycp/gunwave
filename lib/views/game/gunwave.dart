import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/constants/app_gesture.dart';
import 'package:gunwave/data/constants/game/game_constants.dart';
import 'package:gunwave/data/constants/game/game_hub.dart';
import 'package:gunwave/data/constants/game/game_play_mode.dart';
import 'package:gunwave/data/models/character_model.dart';
import 'package:gunwave/data/models/map_model.dart';
import 'package:gunwave/utils/enum_utils.dart';
import 'package:gunwave/views/game/abilities/ability_controller.dart';
import 'package:gunwave/views/game/abilities/ability_registry.dart';
import 'package:gunwave/views/game/abilities/game_ability_context.dart';
import 'package:gunwave/views/game/components/character.dart';
import 'package:gunwave/views/game/components/stage.dart';
import 'package:gunwave/views/game/components/sub_components/attack_button.dart';
import 'package:gunwave/views/game/game_view_model.dart';
import 'package:gunwave/views/game/gesture_controls.dart';

class Gunwave extends FlameGame
    with HasKeyboardHandlerComponents, DragCallbacks, HasCollisionDetection {
  Gunwave(
    this.ref, {
    required this.map,
    required this.gameCharacters,
    required this.playMode,
    required this.onStageCompleted,
    this.onCharacterReachCheckpoint,
    this.onExitRequested,
  });

  @override
  bool get pauseWhenBackgrounded => false;

  WidgetRef ref;
  MapModel map;
  final CharacterModel gameCharacters;
  final GamePlayMode playMode;
  final void Function(bool) onStageCompleted;
  final void Function(bool)? onCharacterReachCheckpoint;
  final VoidCallback? onExitRequested;

  late final JoystickComponent joystick;
  Stage? stage;
  bool _controlsBlocked = false;
  bool _touchAttackPressed = false;
  bool get controlsBlocked => _controlsBlocked;
  set controlsBlocked(bool value) {
    _controlsBlocked = value;
    if (value) {
      _touchAttackPressed = false;
      character.horizontalMovement = 0;
      character.verticalMovement = 0;
      character.triggerAttack = false;
    }
  }

  late final abilities = AbilityController(
    ability: AbilityRegistry.create(gameCharacters.ability),
    context: GameAbilityContext(this),
  );

  /// Shares the same activation path across keyboard, joystick and gesture UI.
  bool activateAbility() => abilities.activate();

  double accoumulatedTime = 0;

  late final Character character = Character(
    gameCharacters,
    onCharacterReachCheckpoint: onCharacterReachCheckpoint,
  );

  @override
  Future<void> onLoad() async {
    images.prefix = '';
    await images.loadAllImages();

    stage = Stage(
      world: map,
      character: character,
      onStageCompleted: onStageCompleted,
    );
    if (stage != null) world = stage!;
    camera = CameraComponent.withFixedResolution(
      width: size.x,
      height: size.y,
      world: world,
    );

    camera.viewfinder.anchor = Anchor.topLeft;

    if (playMode.isJoystick) {
      addJoystick();
    }
    if (!playMode.isKeyboard) addAttachBtn();

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (controlsBlocked) return;
    accoumulatedTime += dt;
    while (accoumulatedTime > GameConstants.refreshRate) {
      camera.viewfinder.position = Vector2(
        (character.scale.x > 0 ? character.x : character.x - character.width) -
            size.x / 4,
        (character.y - (size.y - character.height) / 2),
      );
      if (playMode.isJoystick) updateJoystick();
      if (playMode.isGesture) updateGesture();

      accoumulatedTime -= GameConstants.refreshRate;
      super.update(GameConstants.refreshRate);
      abilities.update(GameConstants.refreshRate);
    }
  }

  @override
  void onRemove() {
    abilities.dispose();
    super.onRemove();
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
        _touchAttackPressed = attack && !controlsBlocked;
        character.triggerAttack = _touchAttackPressed;
      },
      position: Vector2(size.x - 130, size.y - 130),
      size: Vector2.all(64),
    );

    camera.viewport.add(attachBtn);
  }

  void updateJoystick() {
    switch (joystick.direction) {
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

  void updateGesture() {
    final gestureLabel = ref.read(gameViewModel).gesture;
    if (gestureLabel == null) return;
    final gesture = enumFromString(
      AppGesture.values,
      gestureLabel,
      AppGesture.Unknown,
    );
    final controls = GestureControls.fromGesture(gesture);
    character.horizontalMovement = controls.horizontalMovement;
    character.verticalMovement = controls.verticalMovement;
    character.triggerAttack = controls.attack || _touchAttackPressed;
  }
}
