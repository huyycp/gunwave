import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/data/models/character_model.dart';
import 'package:gunwave/data/models/map_model.dart';
import 'package:gunwave/data/models/monster_model.dart';
import 'package:gunwave/views/game/components/character.dart';
import 'package:gunwave/views/game/components/monster.dart';
import 'package:gunwave/views/game/components/stage.dart';
import 'package:gunwave/views/game/components/projectiles/ability_projectile.dart';
import 'package:gunwave/views/game/components/sub_components/collision_component.dart';
import 'package:gunwave/views/game/gunwave.dart';

void main() {
  late Stage stage;
  late StubGame game;
  late Monster first;
  late Monster second;
  setUp(() {
    stage = Stage(
        world: const MapModel(),
        character: Character(const CharacterModel(hp: 100)),
        onStageCompleted: (_) {});
    first = Monster(
        monster: const MonsterModel(hp: 100),
        position: Vector2(100, 0),
        size: Vector2.all(192),
        negXBound: 0,
        posXBound: 0);
    second = Monster(
        monster: const MonsterModel(hp: 100),
        position: Vector2(200, 0),
        size: Vector2.all(192),
        negXBound: 0,
        posXBound: 0);
    stage.monsters.addAll([first, second]);
    game = StubGame(stage);
  });
  AbilityProjectile projectile(bool piercing) => AbilityProjectile(
      origin: Vector2(0, 96),
      direction: Vector2(1, 0),
      damage: 20,
      range: 1024,
      piercing: piercing)
    ..game = game;

  test('piercing projectiles hit each target at most once', () {
    final bolt = projectile(true);
    bolt.update(1);
    expect(first.hp, 80);
    expect(second.hp, 80);
    bolt.update(.1);
    expect(first.hp, 80);
    expect(second.hp, 80);
  });
  test('nonpiercing projectiles stop at the first target', () {
    final bolt = projectile(false);
    bolt.update(1);
    expect(first.hp, 80);
    expect(second.hp, 100);
    bolt.update(1);
    expect(second.hp, 100);
  });
  test('a wall blocks targets beyond it even during a large time step', () {
    stage.collisionGrid.add(
        CollisionComponent(position: Vector2(250, 0), size: Vector2(10, 200)));
    final bolt = projectile(true);
    bolt.update(1);
    expect(first.hp, 80);
    expect(second.hp, 100);
    bolt.update(1);
    expect(second.hp, 100);
  });
}

class StubGame implements Gunwave {
  StubGame(this.stage);
  @override
  final Stage stage;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
