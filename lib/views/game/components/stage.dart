import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:gunwave/data/constants/game/game_building.dart';
import 'package:gunwave/data/constants/game/game_collision.dart';
import 'package:gunwave/data/constants/game/game_components.dart';
import 'package:gunwave/data/constants/game/game_effect.dart';
import 'package:gunwave/data/constants/game/game_layer.dart';
import 'package:gunwave/data/constants/game/game_map.dart';
import 'package:gunwave/data/constants/game/game_monster.dart';
import 'package:gunwave/views/game/components/character.dart';
import 'package:gunwave/views/game/components/sub_components/building.dart';
import 'package:gunwave/views/game/components/sub_components/collision_component.dart';
import 'package:gunwave/views/game/components/monster.dart';
import 'package:gunwave/views/game/components/sub_components/trap.dart';
import 'package:gunwave/views/game/gunwave.dart';

class Stage extends World with HasGameRef<Gunwave> {
  Stage({
    required this.world,
    required this.character,
    required this.onStageCompleted,
    required this.onStageFailed,
  });

  final GameMaps world;
  final Character character;
  final void Function() onStageCompleted;
  final void Function() onStageFailed;

  /// Load world map
  late final TiledComponent component;
  
  final List<CollisionComponent> collisionComponents = [];
  

  final List<Monster> monsters = [];

  bool hasShownDialog = false;

  @override
  FutureOr<void> onLoad() async {
    component = await TiledComponent.load(
      '${world.name}.tmx',
      Vector2.all(64),
    );

    add(component);

    _addSpawnPointsLayer();
    _addBuildingsLayer();
    _addCollisionLayer();

    // debugMode = true;

    return super.onLoad();
  }

  @override
  void update(double dt) {

    checkVictoryCondition();
    super.update(dt);
  }

  void _addSpawnPointsLayer() {
    final spawnPointsLayer = component.tileMap.getLayer<ObjectGroup>(GameLayers.spawnPoints.name);

    if (spawnPointsLayer == null) {
      throw Exception('SpawnPoints layer not found in the map.');
    }

    for (var point in spawnPointsLayer.objects) {
      if (point.class_ == GameComponents.character) {
        character.position = point.position;
        add(character);
      } else if (point.class_ == GameComponents.monster) {
        final negXBound = point.properties.getValue('negXBound') ?? 0;
        final posXBound = point.properties.getValue('posXBound') ?? 0;
        final monster = Monster(
          monster: GameMonsters.redTorch,
          position: point.position,
          size: Vector2(point.width, point.height),
          negXBound: negXBound,
          posXBound: posXBound,
        );
        add(monster);
        monsters.add(monster);
      } else if (point.class_ == GameComponents.effect) {
        final trap = Trap(
          trap: GameEffects.fire,
          position: point.position,
          size: Vector2(point.width, point.height),
        );
        add(trap);
      } else if (point.class_ == GameComponents.building) {
        if (point.name == GameBuildings.blueTower.name) {
          final buildingComponent = Building(
          building: GameBuildings.blueTower,
          position: point.position,
          size: Vector2(point.width, point.height),
        );
        add(buildingComponent);
        }
      } else {
        throw Exception('Unknown spawn point class: ${point.class_}');
      }
    }
  }

  void _addBuildingsLayer() {
    // final buildingsLayer = component.tileMap.getLayer<ObjectGroup>(GameComponents.layers.spawnPoints.name);

    // if (buildingsLayer == null) {
    //   throw Exception('Buildings layer not found in the map.');
    // }

    // for (var point in buildingsLayer.objects) {
    //   if (point.class_ == GameBuilding.blueTower.name) {
    //     final buildingComponent = Building(
    //       building: GameBuilding.blueTower,
    //       position: point.position,
    //       size: Vector2(point.width, point.height),
    //     );
    //     add(buildingComponent);
    //   } else {
    //     throw Exception('Unknown spawn point class: ${point.class_}');
    //   }
    // }
  }

  void _addCollisionLayer() {
    final collisions = component.tileMap.getLayer<ObjectGroup>(GameLayers.collisions.name);

    if (collisions == null) {
      throw Exception('Collisions layer not found in the map.');
    }

    for (var point in collisions.objects) {
      final CollisionComponent component;
      if (point.class_ == GameCollisions.boundary.name) {
        component = CollisionComponent(
          position: point.position,
          size: point.size,
        );
      } else {
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

  void checkVictoryCondition() {
    if (hasShownDialog) return;
    if (character.isDead) {
      hasShownDialog = true;
      Future.delayed(const Duration(seconds: 1), () {
        character.velocity = Vector2.zero();
        onStageFailed();
      });
    }
    if (monsters.every((monster) => monster.isDead)) {
      hasShownDialog = true;
      Future.delayed(const Duration(seconds: 1), () {
        character.velocity = Vector2.zero();
        onStageCompleted();
      });
    }
  }
}