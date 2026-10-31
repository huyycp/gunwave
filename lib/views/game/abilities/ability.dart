import 'package:gunwave/data/models/ability_model.dart';
import 'package:gunwave/data/constants/game/game_constants.dart';
import 'package:gunwave/views/game/abilities/ability_context.dart';

/// Implements one ability; returning false preserves its cooldown.
abstract class Ability {
  const Ability();

  /// The catalog definition associated with this immutable runtime ability.
  AbilityModel get definition;

  /// The world-space radius used by this ability's cast feedback.
  double get feedbackRadius => GameConstants.tileSize / 2;
  bool activate(AbilityContext context);
}

/// Validates Supabase parameters once while constructing an ability.
class AbilityParameters {
  const AbilityParameters(this.definition);
  final AbilityModel definition;

  // Bound remote tuning values to prevent accidental extreme damage/ranges.
  static const double maxDamageMultiplier = 10;
  static const double maxRangeTiles = 50;
  // Positive fractional values below one percent have no useful gameplay effect.
  static const double minPositive = .01;
  // Retain at least five percent attack speed to keep cooldown division finite.
  static const double maxSlow = .95;

  double number(String key, {double min = 0, double max = double.infinity}) {
    final value = definition.parameters[key];
    if (value is! num || !value.isFinite || value < min || value > max) {
      throw FormatException('Invalid ability parameter: $key');
    }
    return value.toDouble();
  }

  int positiveInt(String key) {
    final value = number(key, min: 1);
    if (value != value.truncateToDouble()) {
      throw FormatException('Expected an integer: $key');
    }
    return value.toInt();
  }

  /// Converts a required positive duration from milliseconds to seconds.
  double get duration {
    final value = definition.durationMs;
    if (value == null || value <= 0) {
      throw const FormatException('Ability requires a positive duration_ms');
    }
    return value / 1000;
  }
}
