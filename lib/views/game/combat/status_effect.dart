/// A temporary combat modifier; adding the same key refreshes its state.
class StatusEffect {
  StatusEffect({
    required this.key,
    this.duration,
    this.damageReduction = 0,
    this.damageMultiplier = 1,
    this.moveSpeedMultiplier = 1,
    this.attackSpeedMultiplier = 1,
    this.stunned = false,
    this.invulnerable = false,
    this.charges,
  });

  final String key;
  double? duration;
  final double damageReduction;
  final double damageMultiplier;
  final double moveSpeedMultiplier;
  final double attackSpeedMultiplier;
  final bool stunned;
  final bool invulnerable;
  int? charges;

  bool get expired => (duration != null && duration! <= 0) || charges == 0;
}

/// Combines live modifiers without changing an actor's permanent attributes.
class StatusEffectController {
  final Map<String, StatusEffect> _effects = {};

  bool get isStunned => _effects.values.any((e) => e.stunned);
  bool get isInvulnerable => _effects.values.any((e) => e.invulnerable);
  double get moveSpeedMultiplier =>
      _effects.values.fold(1, (value, e) => value * e.moveSpeedMultiplier);
  double get attackSpeedMultiplier =>
      _effects.values.fold(1, (value, e) => value * e.attackSpeedMultiplier);

  /// Refreshes the effect with the same key instead of stacking it.
  void add(StatusEffect effect) => _effects[effect.key] = effect;

  StatusEffect? operator [](String key) => _effects[key];

  void remove(String key) => _effects.remove(key);

  /// Resolves mitigation for both fire and ordinary combat damage.
  int incomingDamage(int amount) {
    if (amount <= 0 || isInvulnerable) return 0;
    final multiplier = _effects.values.fold<double>(
        1, (value, e) => value * (1 - e.damageReduction.clamp(0, 1)));
    return (amount * multiplier).round();
  }

  /// Consumes one charge per attack swing, irrespective of targets hit.
  double consumeAttackMultiplier() {
    var multiplier = 1.0;
    for (final effect in _effects.values) {
      multiplier *= effect.damageMultiplier;
      if (effect.charges != null) effect.charges = effect.charges! - 1;
    }
    _effects.removeWhere((_, effect) => effect.expired);
    return multiplier;
  }

  /// Advances duration using simulation time rather than wall-clock timers.
  void update(double dt) {
    if (!dt.isFinite || dt <= 0) return;
    for (final effect in _effects.values) {
      if (effect.duration != null) effect.duration = effect.duration! - dt;
    }
    _effects.removeWhere((_, effect) => effect.expired);
  }

  void clear() => _effects.clear();
}
