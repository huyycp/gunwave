import 'ability_test_support.dart';
import 'package:gunwave/views/game/abilities/implementations/built_in_abilities.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/data/models/ability_model.dart';
import 'package:gunwave/views/game/abilities/ability_controller.dart';
import 'package:gunwave/views/game/abilities/ability_registry.dart';
import 'package:gunwave/views/game/combat/status_effect.dart';

void main() {
  AbilityModel definition(String key, Map<String, dynamic> parameters,
          {int? durationMs}) =>
      AbilityModel(
          key: key,
          cooldownMs: 1000,
          durationMs: durationMs,
          parameters: parameters);

  late FakeContext context;
  setUp(() => context = FakeContext());

  AbilityController controller(AbilityModel model) => AbilityController(
      ability: AbilityRegistry.create(model), context: context);

  test('missing, unknown and malformed abilities are safely disabled', () {
    expect(AbilityRegistry.create(null), isNull);
    expect(AbilityRegistry.create(definition('unknown', {})), isNull);
    expect(
        AbilityRegistry.create(definition(
            'bulwark', {'damage_reduction': double.nan},
            durationMs: 3000)),
        isNull);
  });

  test('Freezed abilities compare by value and copy without mutating originals',
      () {
    final model =
        definition('bulwark', {'damage_reduction': .4}, durationMs: 300);
    final original = BulwarkAbility.fromDefinition(model);
    final equal = BulwarkAbility.fromDefinition(model.copyWith());
    expect(original, equal);
    expect(original.hashCode, equal.hashCode);
    final copied = original.copyWith(reduction: .2);
    expect(copied, isNot(original));
    expect(original.reduction, .4);
    expect(copied.definition, model);
    expect(copied.activate(context), isTrue);
    expect(context.caster.effects.incomingDamage(10), 8);
  });

  test('Freezed projectile copy uses its typed piercing configuration', () {
    final original = RiftSlashAbility.fromDefinition(definition('rift_slash',
        {'range_tiles': 2, 'damage_multiplier': 1.5, 'pierces': true}));
    final copied = original.copyWith(piercing: false);
    expect(copied.activate(context), isTrue);
    expect(context.projectiles.single.piercing, isFalse);
    expect(original.piercing, isTrue);
    expect(
        AbilityRegistry.create(definition('rift_slash',
            {'range_tiles': 2, 'damage_multiplier': 1.5, 'pierces': 'true'})),
        isNull);
  });

  test('shield reduces damage, expires and respects cooldown', () {
    final ability = controller(
        definition('bulwark', {'damage_reduction': .4}, durationMs: 300));
    expect(ability.activate(), isTrue);
    expect(context.caster.effects.incomingDamage(10), 6);
    expect(ability.activate(), isFalse);
    context.caster.effects.update(.3);
    expect(context.caster.effects.incomingDamage(10), 10);
    ability.update(1);
    expect(ability.activate(), isTrue);
    ability.dispose();
  });

  test('blocked or dead casters cannot activate; blocked time is frozen', () {
    final ability =
        controller(definition('first_aid', {'heal_max_hp_fraction': .2}));
    context.blocked = true;
    expect(ability.activate(), isFalse);
    context.blocked = false;
    context.caster.hp = 50;
    expect(ability.activate(), isTrue);
    context.blocked = true;
    ability.update(2);
    expect(ability.cooldownRemaining, 1);
    context.blocked = false;
    context.caster.hp = 0;
    expect(ability.activate(), isFalse);
    ability.dispose();
  });

  test('healing is capped; full-health attempts do not spend cooldown', () {
    final ability =
        controller(definition('first_aid', {'heal_max_hp_fraction': .2}));
    expect(ability.activate(), isFalse);
    expect(ability.cooldownRemaining, 0);
    context.caster.hp = 95;
    expect(ability.activate(), isTrue);
    expect(context.caster.hp, 100);
    ability.dispose();
  });

  test('power break consumes exactly three attack swings', () {
    final ability = controller(definition(
        'power_break', {'attack_count': 3, 'damage_multiplier': 1.5}));
    expect(ability.activate(), isTrue);
    expect(
        List.generate(
            4, (_) => context.caster.effects.consumeAttackMultiplier()),
        [1.5, 1.5, 1.5, 1]);
    ability.dispose();
  });

  test('thunder crash damages nearby targets and stun expires', () {
    final target = FakeCombatant();
    context.targets.add(target);
    final ability = controller(definition('thunder_crash',
        {'radius_tiles': 2, 'damage_multiplier': 1.25, 'stun_ms': 800}));
    expect(ability.activate(), isTrue);
    expect(target.hp, 75);
    expect(target.effects.isStunned, isTrue);
    target.effects.update(.8);
    expect(target.effects.isStunned, isFalse);
    expect(context.lastRadius, 128);
    ability.dispose();
  });

  test('rift slash and flame brand configure piercing and range', () {
    final slash = controller(definition('rift_slash',
        {'range_tiles': 2, 'damage_multiplier': 1.5, 'pierces': true}));
    expect(slash.activate(), isTrue);
    expect(
        context.projectiles.single, (damage: 30, range: 128.0, piercing: true));
    final flame = controller(definition(
        'flame_brand', {'range_tiles': 4, 'damage_multiplier': 1.25}));
    expect(flame.activate(), isTrue);
    expect(
        context.projectiles.last, (damage: 25, range: 256.0, piercing: false));
    slash.dispose();
    flame.dispose();
  });

  test('quickstep delegates dash geometry and immunity duration', () {
    final ability = controller(
        definition('quickstep', {'dash_tiles': 1.5}, durationMs: 350));
    expect(ability.activate(), isTrue);
    expect(context.lastDash, (distance: 96.0, duration: .35));
    ability.dispose();
  });

  test('hex seal chooses nearest living target; no target spends no cooldown',
      () {
    final ability = controller(definition(
        'hex_seal', {'move_speed_reduction': .4, 'attack_speed_reduction': .4},
        durationMs: 3000));
    expect(ability.activate(), isFalse);
    expect(ability.cooldownRemaining, 0);
    final far = FakeCombatant()..center = Vector2(100, 0);
    final near = FakeCombatant()..center = Vector2(10, 0);
    context.targets.addAll([far, near]);
    expect(ability.activate(), isTrue);
    expect(near.effects.moveSpeedMultiplier, .6);
    expect(near.effects.attackSpeedMultiplier, .6);
    expect(far.effects.moveSpeedMultiplier, 1);
    near.effects.update(3);
    expect(near.effects.moveSpeedMultiplier, 1);
    ability.dispose();
  });

  test('same-key statuses refresh, clear removes all modifiers', () {
    final effects = StatusEffectController();
    effects.add(StatusEffect(key: 'shield', duration: 1, damageReduction: .4));
    effects.add(StatusEffect(key: 'shield', duration: 2, damageReduction: .4));
    expect(effects.incomingDamage(100), 60);
    effects.update(1);
    expect(effects.incomingDamage(100), 60);
    effects.clear();
    expect(effects.incomingDamage(100), 100);
  });
}
