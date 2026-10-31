import 'dart:math' as math;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gunwave/data/constants/game/game_constants.dart';
import 'package:gunwave/data/models/ability_model.dart';
import 'package:gunwave/views/game/abilities/ability.dart';
import 'package:gunwave/views/game/abilities/ability_context.dart';
import 'package:gunwave/views/game/combat/combatant.dart';
import 'package:gunwave/views/game/combat/status_effect.dart';

part 'built_in_abilities.freezed.dart';

/// Reduces all incoming damage for the configured duration.
@freezed
abstract class BulwarkAbility extends Ability with _$BulwarkAbility {
  const BulwarkAbility._();

  const factory BulwarkAbility({
    required AbilityModel definition,
    required double reduction,
    required double duration,
  }) = _BulwarkAbility;

  /// Validates remote tuning values before creating an immutable ability.
  factory BulwarkAbility.fromDefinition(AbilityModel model) {
    return BulwarkAbility(
        definition: model,
        reduction: AbilityParameters(model).number('damage_reduction', max: 1),
        duration: AbilityParameters(model).duration);
  }

  @override
  bool activate(AbilityContext context) {
    context.caster.effects.add(StatusEffect(
        key: definition.key, duration: duration, damageReduction: reduction));
    return true;
  }
}

/// Enhances a fixed number of normal attack swings.
@freezed
abstract class PowerBreakAbility extends Ability with _$PowerBreakAbility {
  const PowerBreakAbility._();

  const factory PowerBreakAbility({
    required AbilityModel definition,
    required int count,
    required double multiplier,
  }) = _PowerBreakAbility;

  /// Validates remote tuning values before creating an immutable ability.
  factory PowerBreakAbility.fromDefinition(AbilityModel model) {
    return PowerBreakAbility(
        definition: model,
        count: AbilityParameters(model).positiveInt('attack_count'),
        multiplier: AbilityParameters(model).number('damage_multiplier',
            min: 1, max: AbilityParameters.maxDamageMultiplier));
  }

  @override
  bool activate(AbilityContext context) {
    context.caster.effects.add(StatusEffect(
        key: definition.key, charges: count, damageMultiplier: multiplier));
    return true;
  }
}

/// Deals area damage and prevents affected monsters from moving or attacking.
@freezed
abstract class ThunderCrashAbility extends Ability with _$ThunderCrashAbility {
  const ThunderCrashAbility._();

  const factory ThunderCrashAbility({
    required AbilityModel definition,
    required double radius,
    required double multiplier,
    required double stun,
  }) = _ThunderCrashAbility;

  /// Validates remote tuning values before creating an immutable ability.
  factory ThunderCrashAbility.fromDefinition(AbilityModel model) {
    return ThunderCrashAbility(
        definition: model,
        radius: AbilityParameters(model).number('radius_tiles',
                min: AbilityParameters.minPositive,
                max: AbilityParameters.maxRangeTiles) *
            GameConstants.tileSize,
        multiplier: AbilityParameters(model).number('damage_multiplier',
            min: AbilityParameters.minPositive,
            max: AbilityParameters.maxDamageMultiplier),
        stun: AbilityParameters(model).positiveInt('stun_ms') / 1000);
  }

  @override
  double get feedbackRadius => radius;
  @override
  bool activate(AbilityContext context) {
    for (final target in context.targetsWithin(radius)) {
      target.takeDamage(Damage(
          (context.caster.attackPower * multiplier).round(),
          source: DamageSource.ability));
      if (target.isAlive) {
        target.effects.add(
            StatusEffect(key: definition.key, duration: stun, stunned: true));
      }
    }
    return true;
  }
}

/// Sends a slash through monsters until it reaches a wall or its range limit.
@freezed
abstract class RiftSlashAbility extends Ability with _$RiftSlashAbility {
  const RiftSlashAbility._();

  const factory RiftSlashAbility({
    required AbilityModel definition,
    required double range,
    required double multiplier,
    required bool piercing,
  }) = _RiftSlashAbility;

  /// Validates remote tuning values before creating an immutable ability.
  factory RiftSlashAbility.fromDefinition(AbilityModel model) {
    if (model.parameters['pierces'] is! bool) {
      throw const FormatException(
          'Rift slash requires a boolean pierces parameter');
    }
    return RiftSlashAbility(
        definition: model,
        range: AbilityParameters(model).number('range_tiles',
                min: AbilityParameters.minPositive,
                max: AbilityParameters.maxRangeTiles) *
            GameConstants.tileSize,
        multiplier: AbilityParameters(model).number('damage_multiplier',
            min: AbilityParameters.minPositive,
            max: AbilityParameters.maxDamageMultiplier),
        piercing: model.parameters['pierces'] as bool);
  }

  @override
  bool activate(AbilityContext context) {
    context.launchProjectile(
        damage: (context.caster.attackPower * multiplier).round(),
        range: range,
        piercing: piercing);
    return true;
  }
}

/// Restores a fraction of maximum health without exceeding the health cap.
@freezed
abstract class FirstAidAbility extends Ability with _$FirstAidAbility {
  const FirstAidAbility._();

  const factory FirstAidAbility({
    required AbilityModel definition,
    required double fraction,
  }) = _FirstAidAbility;

  /// Validates remote tuning values before creating an immutable ability.
  factory FirstAidAbility.fromDefinition(AbilityModel model) {
    return FirstAidAbility(
        definition: model,
        fraction: AbilityParameters(model).number('heal_max_hp_fraction',
            min: AbilityParameters.minPositive, max: 1));
  }

  @override
  bool activate(AbilityContext context) {
    if (context.caster.health >= context.caster.maxHealth) return false;
    context.caster
        .heal(math.max(1, (context.caster.maxHealth * fraction).round()));
    return true;
  }
}

/// Fires a projectile consumed by the first monster or wall it reaches.
@freezed
abstract class FlameBrandAbility extends Ability with _$FlameBrandAbility {
  const FlameBrandAbility._();

  const factory FlameBrandAbility({
    required AbilityModel definition,
    required double range,
    required double multiplier,
  }) = _FlameBrandAbility;

  /// Validates remote tuning values before creating an immutable ability.
  factory FlameBrandAbility.fromDefinition(AbilityModel model) {
    return FlameBrandAbility(
        definition: model,
        range: AbilityParameters(model).number('range_tiles',
                min: AbilityParameters.minPositive,
                max: AbilityParameters.maxRangeTiles) *
            GameConstants.tileSize,
        multiplier: AbilityParameters(model).number('damage_multiplier',
            min: AbilityParameters.minPositive,
            max: AbilityParameters.maxDamageMultiplier));
  }

  @override
  bool activate(AbilityContext context) {
    context.launchProjectile(
        damage: (context.caster.attackPower * multiplier).round(),
        range: range,
        piercing: false);
    return true;
  }
}

/// Starts a wall-safe dash whose immunity lasts only while dashing.
@freezed
abstract class QuickstepAbility extends Ability with _$QuickstepAbility {
  const QuickstepAbility._();

  const factory QuickstepAbility({
    required AbilityModel definition,
    required double distance,
    required double duration,
  }) = _QuickstepAbility;

  /// Validates remote tuning values before creating an immutable ability.
  factory QuickstepAbility.fromDefinition(AbilityModel model) {
    return QuickstepAbility(
        definition: model,
        distance: AbilityParameters(model).number('dash_tiles',
                min: AbilityParameters.minPositive,
                max: AbilityParameters.maxRangeTiles) *
            GameConstants.tileSize,
        duration: AbilityParameters(model).duration);
  }

  @override
  bool activate(AbilityContext context) =>
      context.dash(distance: distance, duration: duration);
}

/// Slows the nearest monster's movement and attack cadence.
@freezed
abstract class HexSealAbility extends Ability with _$HexSealAbility {
  const HexSealAbility._();

  const factory HexSealAbility({
    required AbilityModel definition,
    required double moveReduction,
    required double attackReduction,
    required double duration,
    required double range,
  }) = _HexSealAbility;

  /// Validates remote tuning values before creating an immutable ability.
  factory HexSealAbility.fromDefinition(AbilityModel model) {
    return HexSealAbility(
        definition: model,
        moveReduction: AbilityParameters(model)
            .number('move_speed_reduction', max: AbilityParameters.maxSlow),
        attackReduction: AbilityParameters(model)
            .number('attack_speed_reduction', max: AbilityParameters.maxSlow),
        duration: AbilityParameters(model).duration,
        // Legacy definitions without range_tiles target within four tiles.
        range: (model.parameters.containsKey('range_tiles')
                ? AbilityParameters(model).number('range_tiles',
                    min: AbilityParameters.minPositive,
                    max: AbilityParameters.maxRangeTiles)
                : 4) *
            GameConstants.tileSize);
  }

  @override
  bool activate(AbilityContext context) {
    Combatant? closest;
    var closestDistance = double.infinity;
    for (final target in context.targetsWithin(range)) {
      final distance =
          target.combatCenter.distanceToSquared(context.caster.combatCenter);
      if (distance < closestDistance) {
        closest = target;
        closestDistance = distance;
      }
    }
    if (closest == null) return false;
    closest.effects.add(StatusEffect(
        key: definition.key,
        duration: duration,
        moveSpeedMultiplier: 1 - moveReduction,
        attackSpeedMultiplier: 1 - attackReduction));
    return true;
  }
}
