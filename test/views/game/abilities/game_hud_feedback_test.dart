import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/data/models/character_model.dart';
import 'package:gunwave/data/models/monster_model.dart';
import 'package:gunwave/data/constants/game/game_hud_style.dart';
import 'package:gunwave/views/game/combat/combatant.dart';
import 'package:gunwave/views/game/combat/status_effect.dart';
import 'package:gunwave/views/game/components/damage_number.dart';
import 'package:gunwave/views/game/components/hit_impact.dart';
import 'package:gunwave/views/game/components/monster.dart';
import 'package:gunwave/views/game/components/sub_components/health_bar.dart';
import 'package:gunwave/views/game/components/sub_components/pixel_health_bar_painter.dart';

import 'ability_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('shared health fill turns critical at one quarter HP', () {
    expect(
      PixelHealthBarPainter.fillColorForRatio(.25),
      GameHudStyle.healthCriticalFill,
    );
    expect(
      PixelHealthBarPainter.fillColorForRatio(.26),
      GameHudStyle.healthFill,
    );
    expect(
      PixelHealthBarPainter.fillColorForRatio(0),
      PixelHealthBarPainter.fillColorForRatio(-1),
    );
    expect(
      PixelHealthBarPainter.fillColorForRatio(1.5),
      PixelHealthBarPainter.fillColorForRatio(1),
    );
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
      expect(game.world.children.whereType<HitImpact>(), hasLength(1));
      expect(number.text, '-6');
      actor.removeFromParent();
      await game.ready();
      final y = number.y;
      game.update(.35);
      expect(number.y, lessThan(y));
      expect(number.isMounted, isTrue);
      game.update(.4);
      await game.ready();
      expect(game.world.children.whereType<HitImpact>(), isEmpty);
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
      expect(monster.healthBar.healthRatio, 0);
      expect(game.world.children.whereType<DamageNumber>().single.text, '-25');
      expect(game.world.children.whereType<HitImpact>(), hasLength(1));
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

  test(
    'hit impact caps visible feedback and releases its slot on expiry',
    () async {
      final game = FlameGame();
      game.onGameResize(Vector2(320, 240));
      // Exercise Flame lifecycle directly without loading a production map.
      // ignore: invalid_use_of_internal_member
      await game.load();
      // ignore: invalid_use_of_internal_member
      game.mount();
      await game.ready();

      for (var i = 0; i < HitImpact.maxVisible + 5; i++) {
        HitImpact.show(game.world, Vector2.zero(), width: 48, height: 56);
      }
      await game.ready();
      expect(
        game.world.children.whereType<HitImpact>(),
        hasLength(HitImpact.maxVisible),
      );

      game.update(HitImpact.duration + .01);
      await game.ready();
      expect(game.world.children.whereType<HitImpact>(), isEmpty);

      HitImpact.show(game.world, Vector2.zero(), width: 0, height: 56);
      await game.ready();
      expect(game.world.children.whereType<HitImpact>(), isEmpty);
      game.onRemove();
    },
  );
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
