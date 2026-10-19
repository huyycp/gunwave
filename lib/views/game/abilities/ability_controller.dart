import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:gunwave/data/constants/game/game_constants.dart';
import 'package:gunwave/views/game/abilities/ability.dart';
import 'package:gunwave/views/game/abilities/ability_context.dart';

/// Owns a caster's ability cooldown and publishes coarse HUD changes.
class AbilityController extends ChangeNotifier {
  AbilityController({required this.ability, required this.context});
  final Ability? ability;
  final AbilityContext context;
  double cooldownRemaining = 0;
  double _feedbackRemaining = 0;
  bool _disposed = false;
  (int, int, int?, bool, bool)? _lastHud;

  /// Whether the cast flash or an ongoing buff is still visible.
  bool get isUsing =>
      _feedbackRemaining > 0 || activeRemaining > 0 || (charges ?? 0) > 0;

  bool get canActivate =>
      !_disposed &&
      ability != null &&
      cooldownRemaining <= 0 &&
      !context.isBlocked &&
      context.caster.isAlive;

  /// Longest remaining duration of this ability on a living combatant.
  double get activeRemaining {
    final key = ability?.definition.key;
    if (key == null) return 0;
    var remaining = 0.0;
    for (final combatant in context.combatants) {
      if (!combatant.isAlive) continue;
      final duration = combatant.effects[key]?.duration ?? 0;
      remaining = math.max(remaining, duration).toDouble();
    }
    return remaining;
  }

  int? get charges =>
      context.caster.effects[ability?.definition.key ?? '']?.charges;

  /// Starts cooldown only when an effect actually activates.
  bool activate() {
    if (!canActivate || !ability!.activate(context)) return false;
    cooldownRemaining = ability!.definition.cooldownMs / 1000;
    _feedbackRemaining = GameConstants.abilityFeedbackDuration;
    context.showFeedback(radius: ability!.feedbackRadius);
    _publish();
    return true;
  }

  void update(double dt) {
    if (_disposed || context.isBlocked || !dt.isFinite || dt <= 0) return;
    cooldownRemaining = math.max(0, cooldownRemaining - dt);
    _feedbackRemaining = math.max(0, _feedbackRemaining - dt);
    _publish();
  }

  void _publish() {
    final hud = (
      cooldownRemaining.ceil(),
      activeRemaining.ceil(),
      charges,
      canActivate,
      isUsing,
    );
    if (hud == _lastHud) return;
    _lastHud = hud;
    notifyListeners();
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    cooldownRemaining = 0;
    _feedbackRemaining = 0;
    context.caster.effects.clear();
    super.dispose();
  }
}
