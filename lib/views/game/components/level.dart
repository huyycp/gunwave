import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:gunwave/data/constants/game_constants.dart';
import 'package:gunwave/utils/enum_utils.dart';
import 'package:gunwave/views/game/components/bullet_component.dart';
import 'package:gunwave/views/game/components/character.dart';
import 'package:gunwave/views/game/components/collision_component.dart';
import 'package:gunwave/views/game/components/fruit_component.dart';
import 'package:gunwave/views/game/components/saw_component.dart';
import 'package:gunwave/views/game/pixel_adventure.dart';

class Level extends World with HasGameRef<PixelAdventure> {
  Level({
    this.world = GameWorlds.level2,
    required this.character,
  });

  final GameWorlds world;
  final Character character;
  late final TiledComponent component;
  final List<CollisionComponent> collisionComponents = [];

  @override
  FutureOr<void> onLoad() async {
    component = await TiledComponent.load(
      '${world.name}.tmx',
      Vector2.all(16)
    );

    add(component);

    _addSpawnPointsLayer();

    _addCollisionLayer();

    // debugMode = true;

    return super.onLoad();
  }

  void _addSpawnPointsLayer() {
    final spawnPointsLayer = component.tileMap.getLayer<ObjectGroup>(GameLayers.spawnPoints.name);

    if (spawnPointsLayer == null) {
      throw Exception('SpawnPoints layer not found in the map.');
    }

    for (var point in spawnPointsLayer.objects) {
      final object = enumFromString(GameObjects.values, point.class_, GameObjects.unknown);
      switch (object) {
        case GameObjects.character:
          character.position = point.position;
          add(character);
          break;
        case GameObjects.fruit:
          final fruit = point.name;
          final fruitComponent = FruitComponent(
            fruit: fruit,
            position: point.position,
            size: point.size,
          );
          add(fruitComponent);
          break;
        case GameObjects.saw:
          final isVertical = point.properties.getValue('isVertical');
          final negOffset = point.properties.getValue('negOffset');
          final posOffset = point.properties.getValue('posOffset');
          final sawComponent = SawComponent(
            position: point.position,
            size: point.size,
            isVertical: isVertical,
            negOffset: negOffset,
            posOffset: posOffset,
          );
          add(sawComponent);
          break;
        default:
          break;
      }
    }
  }

  void _addCollisionLayer() {
    final collisions = component.tileMap.getLayer<ObjectGroup>(GameLayers.collisions.name);

    if (collisions == null) {
      throw Exception('Collisions layer not found in the map.');
    }

    for (var point in collisions.objects) {
      final object = enumFromString(GameObjects.values, point.class_, GameObjects.unknown);
      final CollisionComponent component;
      switch (object) {
        case GameObjects.platform:
          component = CollisionComponent(
            position: point.position,
            size: point.size,
            isPlatform: true,
          );
          break;
        default:
          component = CollisionComponent(
            position: point.position,
            size: point.size,
          );
      }
      collisionComponents.add(component);
    }
    addAll(collisionComponents);
    character.collisionComponents = collisionComponents;
  }

  void shoot() {
    final bullet = BulletComponent(
      direction: character.scale.x > 0 ? 1 : -1,
      position: Vector2(
        character.position.x + (character.scale.x > 0 ? character.size.x : -character.size.x),
        character.position.y + character.size.y / 2,
      ),
    );
    add(bullet);
  }
}