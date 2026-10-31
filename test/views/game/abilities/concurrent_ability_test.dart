import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/data/constants/game/game_play_mode.dart';
import 'package:gunwave/data/models/ability_model.dart';
import 'package:gunwave/data/models/character_model.dart';
import 'package:gunwave/views/game/abilities/ability_context.dart';
import 'package:gunwave/views/game/abilities/ability_controller.dart';
import 'package:gunwave/views/game/abilities/ability_registry.dart';
import 'package:gunwave/views/game/combat/combatant.dart';
import 'package:gunwave/views/game/components/character.dart';
import 'package:gunwave/views/game/gunwave.dart';

import 'ability_test_support.dart';

final definitions = [
  const AbilityModel(
    key: 'bulwark',
    cooldownMs: 14000,
    durationMs: 3000,
    parameters: {'damage_reduction': .4},
  ),
  const AbilityModel(
    key: 'power_break',
    cooldownMs: 14000,
    parameters: {'attack_count': 3, 'damage_multiplier': 1.5},
  ),
  const AbilityModel(
    key: 'thunder_crash',
    cooldownMs: 16000,
    parameters: {'radius_tiles': 2, 'damage_multiplier': 1.25, 'stun_ms': 800},
  ),
  const AbilityModel(
    key: 'rift_slash',
    cooldownMs: 13000,
    parameters: {'range_tiles': 2, 'damage_multiplier': 1.5, 'pierces': true},
  ),
  const AbilityModel(
    key: 'first_aid',
    cooldownMs: 20000,
    parameters: {'heal_max_hp_fraction': .2},
  ),
  const AbilityModel(
    key: 'flame_brand',
    cooldownMs: 10000,
    parameters: {'range_tiles': 4, 'damage_multiplier': 1.25},
  ),
  const AbilityModel(
    key: 'quickstep',
    cooldownMs: 10000,
    durationMs: 350,
    parameters: {'dash_tiles': 1.5},
  ),
  const AbilityModel(
    key: 'hex_seal',
    cooldownMs: 16000,
    durationMs: 3000,
    parameters: {'move_speed_reduction': .4, 'attack_speed_reduction': .4},
  ),
];

void main() {
  late TestCharacter actor;
  late ConcurrentContext context;
  late InputGame game;
  late AbilityController controller;
  void setup(AbilityModel model) {
    actor = TestCharacter(const CharacterModel(hp: 100, str: 20, agi: 100))
      ..hp = 60;
    context = ConcurrentContext(actor);
    controller = AbilityController(
      ability: AbilityRegistry.create(model),
      context: context,
    );
    game = InputGame(controller);
    actor.game = game;
    addTearDown(controller.dispose);
  }

  final movingAttackKeys = {LogicalKeyboardKey.keyW, LogicalKeyboardKey.keyJ};
  KeyDownEvent down(LogicalKeyboardKey key) => KeyDownEvent(
    physicalKey: PhysicalKeyboardKey.keyK,
    logicalKey: key,
    timeStamp: Duration.zero,
  );

  for (final definition in definitions) {
    test('${definition.key} has Freezed value equality', () {
      final first = AbilityRegistry.create(definition);
      final second = AbilityRegistry.create(definition.copyWith());
      expect(first, isNotNull);
      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('${definition.key} activates while W and J remain held', () {
      setup(definition);
      actor.onKeyEvent(down(LogicalKeyboardKey.keyW), movingAttackKeys);
      actor.update(.05);
      expect(actor.isAttacking, isTrue);
      final attackState = actor.current;
      final before = actor.position.clone();
      actor.onKeyEvent(down(LogicalKeyboardKey.keyK), {
        ...movingAttackKeys,
        LogicalKeyboardKey.keyK,
      });
      expect(controller.cooldownRemaining, greaterThan(0));
      expect(actor.verticalMovement, -1);
      expect(actor.triggerAttack, isTrue);
      expect(actor.isAttacking, isTrue);
      expect(actor.current, attackState);
      actor.update(.1);
      expect(actor.position.y, lessThan(before.y));
      expect(actor.current, attackState);
    });
  }

  test('Power Break cast mid-swing buffs the next swing only', () {
    setup(definitions.firstWhere((a) => a.key == 'power_break'));
    actor.triggerAttack = true;
    actor.attack();
    expect(controller.activate(), isTrue);
    expect(controller.charges, 3);
    actor.attack();
    expect(controller.charges, 3);
    actor.current = GameCharacterStates.idle;
    actor.isAttacking = false;
    actor.attack();
    expect(controller.charges, 2);
  });

  test(
    'holding K does not recast after cooldown; releasing J preserves movement',
    () {
      setup(definitions.firstWhere((a) => a.key == 'first_aid'));
      actor.onKeyEvent(down(LogicalKeyboardKey.keyK), {
        ...movingAttackKeys,
        LogicalKeyboardKey.keyK,
      });
      expect(actor.hp, 80);
      controller.update(21);
      actor.onKeyEvent(
        const KeyRepeatEvent(
          physicalKey: PhysicalKeyboardKey.keyK,
          logicalKey: LogicalKeyboardKey.keyK,
          timeStamp: Duration.zero,
        ),
        {...movingAttackKeys, LogicalKeyboardKey.keyK},
      );
      expect(actor.hp, 80);
      actor.onKeyEvent(
        const KeyUpEvent(
          physicalKey: PhysicalKeyboardKey.keyJ,
          logicalKey: LogicalKeyboardKey.keyJ,
          timeStamp: Duration.zero,
        ),
        {LogicalKeyboardKey.keyW},
      );
      expect(actor.triggerAttack, isFalse);
      expect(actor.verticalMovement, -1);
    },
  );

  test('Escape requests exit even with gameplay blocked and does not cast', () {
    setup(definitions.first);
    game.controlsBlocked = true;
    actor.onKeyEvent(down(LogicalKeyboardKey.escape), {
      LogicalKeyboardKey.escape,
    });
    expect(game.exitRequests, 1);
    expect(controller.cooldownRemaining, 0);
  });

  test('blocked keyboard input cannot cast or keep an old movement active', () {
    setup(definitions.first);
    game.controlsBlocked = true;
    actor.verticalMovement = -1;
    actor.triggerAttack = true;
    actor.onKeyEvent(down(LogicalKeyboardKey.keyK), {
      ...movingAttackKeys,
      LogicalKeyboardKey.keyK,
    });
    expect(controller.cooldownRemaining, 0);
    expect(actor.verticalMovement, 0);
    expect(actor.triggerAttack, isFalse);
  });
}

class ConcurrentContext implements AbilityContext {
  ConcurrentContext(this.caster);
  @override
  final TestCharacter caster;
  @override
  bool get isBlocked => false;
  final target = FakeCombatant();
  @override
  Iterable<Combatant> get combatants => [caster, target];
  @override
  Iterable<Combatant> targetsWithin(double radius) => [target];
  @override
  bool dash({required double distance, required double duration}) =>
      caster.startDash(distance: distance, duration: duration);
  @override
  void launchProjectile({
    required int damage,
    required double range,
    required bool piercing,
  }) {}
  @override
  void showFeedback({required double radius}) {}
}

class InputGame implements Gunwave {
  InputGame(this.abilities);
  int exitRequests = 0;
  @override
  void Function()? get onExitRequested =>
      () => exitRequests++;
  @override
  final AbilityController abilities;
  @override
  final playMode = GamePlayMode.keyboard;
  @override
  bool controlsBlocked = false;
  @override
  bool activateAbility() => abilities.activate();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
