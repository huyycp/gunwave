import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/constants/app_gesture.dart';
import 'package:gunwave/data/constants/game/game_constants.dart';
import 'package:gunwave/data/constants/game/game_hud_style.dart';
import 'package:gunwave/data/constants/game/game_play_mode.dart';
import 'package:gunwave/data/models/campaign_stage_model.dart';
import 'package:gunwave/data/models/character_model.dart';
import 'package:gunwave/data/models/map_model.dart';
import 'package:gunwave/utils/enum_utils.dart';
import 'package:gunwave/views/game/abilities/ability_controller.dart';
import 'package:gunwave/views/game/abilities/ability_registry.dart';
import 'package:gunwave/views/game/abilities/game_ability_context.dart';
import 'package:gunwave/views/game/components/character.dart';
import 'package:gunwave/views/game/components/monster.dart';
import 'package:gunwave/views/game/components/stage.dart';
import 'package:gunwave/views/game/components/sub_components/attack_button.dart';
import 'package:gunwave/views/game/game_view_model.dart';
import 'package:gunwave/views/game/gesture_controls.dart';
import 'package:gunwave/views/game/game_touch_control_layout.dart';
import 'package:gunwave/views/game/components/sub_components/pixel_joystick_disc.dart';
import 'package:gunwave/views/game/ui/campaign_ui_labels.dart';
import 'package:gunwave/views/game/ui/components/combat_hud_component.dart';
import 'package:gunwave/views/game/ui/components/pause_menu_component.dart';
import 'package:gunwave/views/game/ui/components/stage_result_component.dart';

class Gunwave extends FlameGame
    with HasKeyboardHandlerComponents, DragCallbacks, HasCollisionDetection {
  Gunwave(
    this.ref, {
    this.map,
    this.campaignStage,
    required this.gameCharacters,
    required this.playMode,
    required this.onStageCompleted,
    this.campaignUiLabels,
    this.safeAreaInsets = EdgeInsets.zero,
    this.onCharacterReachCheckpoint,
    this.onExitRequested,
    this.onPauseRequested,
  }) : assert((map != null) != (campaignStage != null));

  @override
  bool get pauseWhenBackgrounded => campaignStage != null;

  WidgetRef ref;
  final MapModel? map;
  final CampaignStageModel? campaignStage;
  final CharacterModel gameCharacters;
  final GamePlayMode playMode;
  final void Function(bool) onStageCompleted;
  final CampaignUiLabels? campaignUiLabels;

  /// OS padding used to keep Flame touch controls clear of system UI.
  final EdgeInsets safeAreaInsets;
  final void Function(bool)? onCharacterReachCheckpoint;
  final VoidCallback? onExitRequested;
  final VoidCallback? onPauseRequested;

  late final JoystickComponent joystick;
  Stage? stage;
  bool _controlsBlocked = false;
  bool _isRemoving = false;
  CombatHudComponent? _combatHud;
  PauseMenuComponent? _pauseMenu;
  StageResultComponent? _stageResult;
  String? _pendingCampaignNotice;
  bool _touchAttackPressed = false;
  bool get controlsBlocked => _controlsBlocked;
  set controlsBlocked(bool value) {
    _controlsBlocked = value;
    if (value) {
      accoumulatedTime = 0;
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
      campaignStage: campaignStage,
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
    if (campaignStage != null) {
      final labels = campaignUiLabels;
      if (labels == null) {
        throw StateError('Campaign UI labels are required for campaign play.');
      }
      _combatHud = await CombatHudComponent.load(
        images,
        labels: labels,
        safeAreaInsets: safeAreaInsets,
        showAbility: abilities.ability != null,
        showKeyboardGuide: playMode.isKeyboard,
        onPause: () => onPauseRequested?.call(),
        onActivateAbility: activateAbility,
      );
      camera.viewport.add(_combatHud!);
      _updateCombatHud();
      final pendingNotice = _pendingCampaignNotice;
      if (pendingNotice != null) {
        _combatHud!.showNotice(pendingNotice);
        _pendingCampaignNotice = null;
      }
    }

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (controlsBlocked) {
      _updateCombatHud();
      super.update(0);
      return;
    }
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
      _updateCombatHud();
    }
  }

  /// Opens the Flame pause menu and blocks combat simulation while it is open.
  Future<void> showPauseMenu({
    required VoidCallback onResume,
    required VoidCallback onExitConfirmed,
  }) async {
    if (campaignStage == null || _pauseMenu != null || _stageResult != null) {
      return;
    }
    final labels = campaignUiLabels;
    if (labels == null) return;
    controlsBlocked = true;
    final menu = await PauseMenuComponent.load(
      images,
      labels: labels,
      safeAreaInsets: safeAreaInsets,
      onResume: () {
        hidePauseMenu();
        controlsBlocked = false;
        onResume();
      },
      onExitConfirmed: onExitConfirmed,
    );
    if (_isRemoving || _stageResult != null) return;
    _pauseMenu = menu;
    camera.viewport.add(menu);
  }

  /// Removes the pause menu when the host handles a confirmed route exit.
  void hidePauseMenu() {
    _pauseMenu?.removeFromParent();
    _pauseMenu = null;
  }

  /// Displays gesture/input feedback through the campaign's asset HUD.
  void showCampaignNotice(String message) {
    final hud = _combatHud;
    if (hud == null) {
      _pendingCampaignNotice = message;
      return;
    }
    hud.showNotice(message);
  }

  /// Displays the result and reward snapshot without applying any reward.
  Future<void> showStageResult({
    required bool isSuccess,
    required List<String> rewardLines,
    required VoidCallback onRetry,
    VoidCallback? onContinue,
    required VoidCallback onCampaign,
  }) async {
    if (campaignStage == null || _stageResult != null) return;
    final labels = campaignUiLabels;
    if (labels == null) return;
    controlsBlocked = true;
    hidePauseMenu();
    final result = await StageResultComponent.load(
      images,
      labels: labels,
      safeAreaInsets: safeAreaInsets,
      isSuccess: isSuccess,
      rewardLines: rewardLines,
      onRetry: onRetry,
      onContinue: onContinue,
      onCampaign: onCampaign,
    );
    if (_isRemoving) return;
    _stageResult = result;
    camera.viewport.add(result);
  }

  @override
  void onRemove() {
    _isRemoving = true;
    abilities.dispose();
    super.onRemove();
  }

  void _updateCombatHud() {
    final hud = _combatHud;
    final stageComponent = stage;
    final labels = campaignUiLabels;
    if (hud == null || stageComponent == null || labels == null) return;

    final round = stageComponent.currentRound;
    final boss = round?.isBoss == true
        ? stageComponent.monsters.fold<Monster?>(
            null,
            (current, monster) =>
                current == null || monster.maxHealth > current.maxHealth
                ? monster
                : current,
          )
        : null;
    final cooldown = abilities.cooldownRemaining.ceil();
    final active = abilities.activeRemaining.ceil();
    final abilityStatus = cooldown > 0
        ? labels.abilityCooldown(cooldown)
        : active > 0
        ? labels.abilityActive(active)
        : labels.ready;

    hud.updateSnapshot(
      CombatHudSnapshot(
        playerHealth: character.hp,
        playerMaxHealth: character.maxHealth,
        round: round?.number ?? 1,
        roundCount: campaignStage!.rounds.length,
        abilityAvailable: abilities.canActivate,
        abilityStatus: abilityStatus,
        bossHealth: boss?.hp,
        bossMaxHealth: boss?.maxHealth,
      ),
    );
  }

  void addJoystick() {
    joystick = JoystickComponent(
      knob: PixelJoystickDisc.knob(),
      background: PixelJoystickDisc.background(),
      margin: GameTouchControlLayout.joystickMargin(safeAreaInsets),
    );

    camera.viewport.add(joystick);
  }

  void addAttachBtn() {
    final attachBtn = AttachButton(
      onAttack: (bool attack) {
        _touchAttackPressed = attack && !controlsBlocked;
        character.triggerAttack = _touchAttackPressed;
      },
      position: GameTouchControlLayout.attackPosition(size, safeAreaInsets),
      size: Vector2.all(GameHudStyle.touchAttackSize),
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
