import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/views/game/abilities/ability_visual_style.dart';
import 'package:gunwave/views/game/components/ability_feedback.dart';
import 'package:gunwave/views/game/combat/status_effect.dart';
import 'ability_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('shockwave stays at cast origin while stun stars follow the target', () {
    final target = FakeCombatant();
    final shockwave =
        AbilityFeedback(style: AbilityVisualStyle.thunderCrash, target: target);
    target.center.x = 80;
    shockwave.update(.1);
    expect(shockwave.position.x, 0);
    target.effects
        .add(StatusEffect(key: 'thunder_crash', duration: .8, stunned: true));
    final stars =
        AbilityFeedback(style: AbilityVisualStyle.thunderCrash, target: target);
    target.center.x = 100;
    stars.update(.1);
    expect(stars.position.x, 100);
  });

  test(
      'directional cast feedback keeps its original facing when the actor turns',
      () {
    final direction = Vector2(1, 0);
    final slash = AbilityFeedback(
        style: AbilityVisualStyle.riftSlash,
        target: FakeCombatant(),
        direction: direction);
    direction.setValues(0, 1);
    expect(slash.direction, Vector2(1, 0));
  });
  test('all eight abilities produce distinct visible shapes', () async {
    final fingerprints = <int>{};
    for (final style in AbilityVisualStyle.values) {
      final effect = AbilityFeedback(style: style, target: FakeCombatant());
      effect.update(.2);
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder)..translate(64, 64);
      effect.render(canvas);
      final picture = recorder.endRecording();
      final image = await picture.toImage(192, 192);
      final data = await image.toByteData();
      final bytes = data!.buffer.asUint8List();
      expect(bytes.any((value) => value != 0), isTrue, reason: style.key);
      fingerprints.add(Object.hashAll(bytes));
      image.dispose();
      picture.dispose();
    }
    expect(fingerprints.length, 8);
  });

  test('shield visual follows movement and ends when the shield expires', () {
    final target = FakeCombatant();
    target.effects.add(StatusEffect(key: 'bulwark', duration: 3));
    final effect =
        AbilityFeedback(style: AbilityVisualStyle.bulwark, target: target);
    target.center.x = 80;
    effect.update(1);
    expect(effect.position.x, 80);
    expect(effect.isFinished, isFalse);
    target.effects.update(3);
    effect.update(.01);
    expect(effect.isFinished, isTrue);
  });

  test('charged visual remains until the last enhanced swing is consumed', () {
    final target = FakeCombatant();
    target.effects.add(
        StatusEffect(key: 'power_break', charges: 1, damageMultiplier: 1.5));
    final effect =
        AbilityFeedback(style: AbilityVisualStyle.powerBreak, target: target);
    effect.update(5);
    expect(effect.isFinished, isFalse);
    target.effects.consumeAttackMultiplier();
    effect.update(.01);
    expect(effect.isFinished, isTrue);
  });

  test('instant feedback expires and death removes persistent feedback', () {
    final target = FakeCombatant();
    final heal =
        AbilityFeedback(style: AbilityVisualStyle.firstAid, target: target);
    heal.update(2);
    expect(heal.isFinished, isTrue);
    target.effects.add(StatusEffect(key: 'hex_seal', duration: 3));
    final hex =
        AbilityFeedback(style: AbilityVisualStyle.hexSeal, target: target);
    target.hp = 0;
    hex.update(.01);
    expect(hex.isFinished, isTrue);
  });
}
