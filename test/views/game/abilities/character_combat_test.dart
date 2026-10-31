import 'ability_test_support.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/data/models/character_model.dart';
import 'package:gunwave/views/game/combat/combatant.dart';
import 'package:gunwave/views/game/combat/status_effect.dart';
import 'package:gunwave/views/game/components/character.dart';
import 'package:gunwave/views/game/components/sub_components/collision_component.dart';
import 'package:gunwave/views/game/components/sub_components/collision_grid.dart';

void main() {
  late Character character;
  setUp(() => character =
      TestCharacter(const CharacterModel(hp: 100, str: 20, agi: 100)));

  test('shield mitigates fire and preserves collision detection', () {
    character.effects
        .add(StatusEffect(key: 'bulwark', duration: 3, damageReduction: .4));
    final collisionType = character.hitbox.collisionType;
    expect(character.takeDamage(const Damage(10, source: DamageSource.fire)),
        isTrue);
    expect(character.hp, 94);
    expect(character.hitbox.collisionType, collisionType);
    expect(character.hitbox.collisionType, isNot(CollisionType.inactive));
    expect(character.takeDamage(const Damage(10, source: DamageSource.monster)),
        isFalse);
  });

  test('quickstep grants damage immunity without disabling checkpoints', () {
    expect(character.startDash(distance: 96, duration: .35), isTrue);
    expect(character.takeDamage(const Damage(10, source: DamageSource.fire)),
        isFalse);
    expect(character.hitbox.collisionType, isNot(CollisionType.inactive));
    expect(character.startDash(distance: 96, duration: .35), isFalse);
  });

  test('healing and lethal damage respect health boundaries', () {
    character.hp = 95;
    character.heal(20);
    expect(character.hp, 100);
    character.takeDamage(const Damage(999, source: DamageSource.ability));
    expect(character.hp, 0);
    character.heal(100);
    expect(character.hp, 0);
  });
  test('dash stops at a wall and clears immunity when it stops', () {
    character.collisionGrid = CollisionGrid(cellSize: 64)
      ..add(CollisionComponent(
          position: Vector2(160, 90), size: Vector2(20, 100)));
    character.startDash(distance: 96, duration: .35);
    character.update(.5);
    expect(character.position.x, closeTo(40, .0001));
    expect(character.effects.isInvulnerable, isFalse);
  });

  test('unobstructed dash travels its exact range and finishes', () {
    character.startDash(distance: 96, duration: .35);
    character.update(.6);
    expect(character.position.x, closeTo(96, .0001));
    expect(character.effects.isInvulnerable, isFalse);
    expect(character.startDash(distance: 96, duration: .35), isTrue);
  });
}
