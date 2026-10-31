import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/data/models/character_model.dart';
import 'package:gunwave/data/models/monster_model.dart';
import 'package:gunwave/l10n/app_localizations.dart';
import 'package:gunwave/views/game/combat/combatant.dart';
import 'package:gunwave/views/game/combat/status_effect.dart';
import 'package:gunwave/views/game/components/damage_number.dart';
import 'package:gunwave/views/game/components/monster.dart';
import 'package:gunwave/views/game/components/sub_components/health_bar.dart';
import 'package:gunwave/views/game/widgets/player_health_hud.dart';

import 'ability_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('player bar updates numbers and fill after damage and healing', (
    tester,
  ) async {
    final actor = TestCharacter(const CharacterModel(hp: 100));
    addTearDown(actor.healthNotifier.dispose);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SizedBox(
            width: 160,
            child: PlayerHealthHud(
              health: actor.healthNotifier,
              maxHealth: actor.maxHealth,
            ),
          ),
        ),
      ),
    );
    expect(find.text('100 / 100'), findsOneWidget);
    expect(actor.children.whereType<HealthBar>(), isEmpty);
    actor.takeDamage(const Damage(30, source: DamageSource.fire));
    await tester.pump();
    expect(find.text('70 / 100'), findsOneWidget);
    expect(
      tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
          .value,
      .7,
    );
    actor.heal(10);
    await tester.pump();
    expect(find.text('80 / 100'), findsOneWidget);
  });

  test(
    'damage text rises, survives actor death and removes itself; cap resets',
    () async {
      final game = FlameGame();
      game.onGameResize(Vector2(320, 240));
      // Exercise Flame lifecycle directly without loading a production map.
      // ignore: invalid_use_of_internal_member
      await game.load();
      // ignore: invalid_use_of_internal_member
      game.mount();
      await game.ready();
      final actor = _UnloadedCharacter(const CharacterModel(hp: 100));
      game.world.add(actor);
      await game.ready();
      actor.effects.add(
        StatusEffect(key: 'bulwark', duration: 3, damageReduction: .4),
      );
      actor.takeDamage(const Damage(10, source: DamageSource.fire));
      await game.ready();
      final number = game.world.children.whereType<DamageNumber>().single;
      expect(number.text, '-6');
      actor.removeFromParent();
      await game.ready();
      final y = number.y;
      game.update(.35);
      expect(number.y, lessThan(y));
      expect(number.isMounted, isTrue);
      game.update(.4);
      await game.ready();
      expect(game.world.children.whereType<DamageNumber>(), isEmpty);
      for (var i = 0; i < DamageNumber.maxVisible + 10; i++) {
        DamageNumber.show(game.world, Vector2.zero(), 1, player: false);
      }
      await game.ready();
      expect(
        game.world.children.whereType<DamageNumber>().length,
        DamageNumber.maxVisible,
      );
      game.update(1);
      await game.ready();
      DamageNumber.show(game.world, Vector2.zero(), 2, player: true);
      await game.ready();
      expect(game.world.children.whereType<DamageNumber>().single.text, '-2');
      game.onRemove();
      actor.healthNotifier.dispose();
    },
  );

  test(
    'monster HP numbers clamp and lethal text shows actual HP lost',
    () async {
      final game = FlameGame();
      game.onGameResize(Vector2(320, 240));
      // Exercise Flame lifecycle directly without loading a production map.
      // ignore: invalid_use_of_internal_member
      await game.load();
      // ignore: invalid_use_of_internal_member
      game.mount();
      final monster = _UnloadedMonster();
      game.world.add(monster);
      await game.ready();
      expect(
        monster.takeDamage(const Damage(999, source: DamageSource.ability)),
        isTrue,
      );
      await game.ready();
      expect(monster.healthBar.label, '0 / 25');
      expect(game.world.children.whereType<DamageNumber>().single.text, '-25');
      expect(
        monster.takeDamage(const Damage(1, source: DamageSource.melee)),
        isFalse,
      );
      expect(game.world.children.whereType<DamageNumber>().length, 1);
      game.onRemove();
    },
  );

  test('zero max HP bar safely renders and clamps updates', () {
    final bar = HealthBar(maxHealth: 0, currentHealth: 0, width: 64);
    bar.updateHealth(999);
    expect(bar.label, '0 / 0');
  });
}

class _UnloadedCharacter extends TestCharacter {
  _UnloadedCharacter(super.character);
  @override
  void onLoad() {}
}

class _UnloadedMonster extends Monster {
  _UnloadedMonster()
    : super(
        monster: const MonsterModel(hp: 25),
        position: Vector2.zero(),
        size: Vector2.all(192),
        negXBound: 0,
        posXBound: 0,
      );
  @override
  Future<void> onLoad() async {}
}
