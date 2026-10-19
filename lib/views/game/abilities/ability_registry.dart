import 'package:gunwave/data/models/ability_model.dart';
import 'package:gunwave/utils/logger/app_logger.dart';
import 'package:gunwave/views/game/abilities/ability.dart';
import 'package:gunwave/views/game/abilities/implementations/built_in_abilities.dart';

/// Registers ability implementations by the stable key stored in Supabase.
class AbilityRegistry {
  AbilityRegistry._();
  static const _logger = AppLogger(AbilityRegistry);
  static final _factories = <String, Ability Function(AbilityModel)>{
    'bulwark': BulwarkAbility.fromDefinition,
    'power_break': PowerBreakAbility.fromDefinition,
    'thunder_crash': ThunderCrashAbility.fromDefinition,
    'rift_slash': RiftSlashAbility.fromDefinition,
    'first_aid': FirstAidAbility.fromDefinition,
    'flame_brand': FlameBrandAbility.fromDefinition,
    'quickstep': QuickstepAbility.fromDefinition,
    'hex_seal': HexSealAbility.fromDefinition,
  };

  /// Disables absent, unsupported or malformed definitions without crashing play.
  static Ability? create(AbilityModel? model) {
    if (model == null) return null;
    final factory = _factories[model.key];
    if (factory == null || model.cooldownMs <= 0) {
      _logger.warning(
          'create', 'Unsupported ability or invalid cooldown: ${model.key}');
      return null;
    }
    try {
      return factory(model);
    } on FormatException catch (error) {
      _logger.warning('create', '${model.key}: ${error.message}');
      return null;
    }
  }
}
