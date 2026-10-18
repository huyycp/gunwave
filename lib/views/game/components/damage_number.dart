import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'package:gunwave/data/constants/game/game_hud_style.dart';

/// Shows actual HP lost at the hit position, then rises and removes itself.
/// Attached to the world so death/removal and sprite flipping do not affect it.
class DamageNumber extends TextComponent {
  DamageNumber({
    required int amount,
    required Vector2 origin,
    required bool player,
  }) : super(
         text: '-$amount',
         position: origin.clone(),
         anchor: Anchor.bottomCenter,
         priority: 100,
         textRenderer: TextPaint(
           style: TextStyle(
             fontSize: fontSize,
             fontWeight: FontWeight.bold,
             color: player
                 ? GameHudStyle.damageTaken
                 : GameHudStyle.damageDealt,
             shadows: const [Shadow(blurRadius: 2, color: Colors.black)],
           ),
         ),
       );

  // A short rise stays readable without covering the next attack's number.
  static const duration = .7;
  static const rise = 32.0;
  static const fontSize = 16.0;
  static const maxVisible = 32;
  static final _visible = Expando<int>();
  Component? _owner;

  /// Bounds text components during crowded encounters and skips detached actors.
  static void show(
    Component? world,
    Vector2 origin,
    int amount, {
    required bool player,
  }) {
    if (world == null || amount <= 0) return;
    final count = _visible[world] ?? 0;
    if (count >= maxVisible) return;
    // Reserve before add() mounts: simultaneous hits must share the same cap.
    _visible[world] = count + 1;
    world.add(
      DamageNumber(amount: amount, origin: origin, player: player)
        .._owner = world,
    );
  }

  @override
  void onRemove() {
    final owner = _owner;
    if (owner != null) {
      _visible[owner] = (_visible[owner] ?? 1) - 1;
      _owner = null;
    }
    super.onRemove();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(
      MoveEffect.by(
        Vector2(0, -rise),
        EffectController(duration: duration, curve: Curves.easeOut),
      ),
    );
    add(RemoveEffect(delay: duration));
  }
}
