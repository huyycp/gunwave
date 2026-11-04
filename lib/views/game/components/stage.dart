import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:gunwave/data/constants/game/game_building.dart';
import 'package:gunwave/data/constants/game/game_collision.dart';
import 'package:gunwave/data/constants/game/game_components.dart';
import 'package:gunwave/data/constants/game/game_constants.dart';
import 'package:gunwave/data/constants/game/game_effect.dart';
import 'package:gunwave/data/constants/game/game_layer.dart';
import 'package:gunwave/data/data_sources/local/campaign_content_data_source.dart';
import 'package:gunwave/data/models/campaign_stage_model.dart';
import 'package:gunwave/data/models/map_model.dart';
import 'package:gunwave/data/models/monster_model.dart';
import 'package:gunwave/data/models/stage_round_model.dart';
import 'package:gunwave/views/game/components/character.dart';
import 'package:gunwave/views/game/components/campaign_spawn_marker_validator.dart';
import 'package:gunwave/views/game/components/round_director.dart';
import 'package:gunwave/views/game/components/sub_components/building.dart';
import 'package:gunwave/views/game/components/sub_components/collision_component.dart';
import 'package:gunwave/views/game/components/sub_components/collision_grid.dart';
import 'package:gunwave/views/game/components/monster.dart';
import 'package:gunwave/views/game/components/sub_components/trap.dart';
import 'package:gunwave/views/game/gunwave.dart';

class Stage extends World with HasGameRef<Gunwave> {
  Stage({
    this.world,
    this.campaignStage,
    required this.character,
    required this.onStageCompleted,
  }) : assert((world != null) != (campaignStage != null));

  /// Legacy room map, retained until the campaign launch replaces that route.
  final MapModel? world;
  final CampaignStageModel? campaignStage;
  final Character character;
  final void Function(bool) onStageCompleted;

  /// Load world map
  late final TiledComponent component;

  final List<CollisionComponent> collisionComponents = [];
  final collisionGrid = CollisionGrid(cellSize: GameConstants.tileSize);

  final List<Monster> monsters = [];
  final Map<String, TiledObject> _campaignSpawnMarkers = {};

  RoundDirector? roundDirector;
  StageRoundModel? get currentRound => roundDirector?.currentRound;

  bool hasShownDialog = false;

  @override
  FutureOr<void> onLoad() async {
    final mapName = campaignStage != null
        ? campaignStage!.map?.name
        : world?.name;
    if (mapName == null) {
      throw const CampaignContentException(
        'The campaign stage does not resolve to a local Tiled map.',
      );
    }
    try {
      component = await TiledComponent.load(
        '$mapName.tmx',
        Vector2.all(GameConstants.tileSize),
      );
    } catch (error) {
      if (campaignStage == null) rethrow;
      throw CampaignContentException(
        'Could not load Tiled map "$mapName": $error',
      );
    }

    add(component);

    _addSpawnPointsLayer();
    if (campaignStage case final stage?) {
      validateCampaignSpawnMarkers(stage, _campaignSpawnMarkers.keys.toSet());
    }
    _addBuildingsLayer();
    _addCollisionLayer();
    if (campaignStage != null) _startCampaignRounds();

    // debugMode = true;

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (campaignStage != null) {
      if (character.isDead) {
        _finishCampaign(false);
      } else {
        roundDirector?.update(
          dt,
          activeEnemyCount: monsters.where((monster) => monster.isAlive).length,
          isPaused: game.controlsBlocked,
          resultsVisible: hasShownDialog,
        );
      }
    } else {
      checkVictoryCondition();
    }
    super.update(dt);
  }

  void _addSpawnPointsLayer() {
    final spawnPointsLayer = component.tileMap.getLayer<ObjectGroup>(
      GameLayers.spawnPoints.name,
    );

    if (spawnPointsLayer == null) {
      if (campaignStage case final stage?) {
        throw CampaignContentException(
          'Tiled map "${stage.mapKey}" has no spawn_points layer.',
        );
      }
      throw Exception('SpawnPoints layer not found in the map.');
    }

    for (var point in spawnPointsLayer.objects) {
      if (point.class_ == GameComponents.character) {
        character.position = point.position;
        add(character);
      } else if (point.class_ == GameComponents.monster) {
        if (campaignStage != null) {
          if (_campaignSpawnMarkers.containsKey(point.name)) {
            throw CampaignContentException(
              'Tiled map "${campaignStage!.mapKey}" has duplicate monster spawn marker "${point.name}".',
            );
          }
          _campaignSpawnMarkers[point.name] = point;
        } else {
          MonsterModel? monsterModel;
          for (final candidate in world!.monsters) {
            if (candidate.filename == point.name) {
              monsterModel = candidate;
              break;
            }
          }
          if (monsterModel != null) {
            final monster = _createMonster(monsterModel, point);
            add(monster);
            monsters.add(monster);
          }
        }
      } else if (point.class_ == GameComponents.effect) {
        if (point.name == GameEffects.fire.name) {
          final effect = GameEffects.fire;
          final effectComponent = Trap(
            trap: effect,
            position: point.position,
            size: Vector2(point.width, point.height),
            isVisibleOnTriggered: true,
          );
          add(effectComponent);
        }
      } else if (point.class_ == GameComponents.building) {
        final isCheckpoint =
            point.properties.getValue('is_checkpoint') ?? false;
        if (point.name == GameBuildings.blueTower.name) {
          final buildingComponent = Building(
            building: GameBuildings.blueTower,
            position: point.position,
            size: Vector2(point.width, point.height),
            isCheckpoint: isCheckpoint,
          );
          add(buildingComponent);
        }
      } else {
        final message = 'Unknown spawn point class: ${point.class_}';
        if (campaignStage != null) {
          throw CampaignContentException(message);
        }
        throw Exception(message);
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
    final collisions = component.tileMap.getLayer<ObjectGroup>(
      GameLayers.collisions.name,
    );

    if (collisions == null) {
      if (campaignStage case final stage?) {
        throw CampaignContentException(
          'Tiled map "${stage.mapKey}" has no collisions layer.',
        );
      }
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
      collisionGrid.add(component);
    }
    addAll(collisionComponents);
    character.collisionGrid = collisionGrid;
    for (final monster in monsters) {
      monster.collisionGrid = collisionGrid;
    }
  }

  Monster _createMonster(MonsterModel model, TiledObject marker) => Monster(
    monster: model,
    position: marker.position,
    size: Vector2(marker.width, marker.height),
    negXBound: _readBound(marker, 'negXBound'),
    posXBound: _readBound(marker, 'posXBound'),
  )..collisionGrid = collisionGrid;

  double _readBound(TiledObject marker, String propertyName) {
    final value = marker.properties.getValue(propertyName);
    return value is num ? value.toDouble() : 0;
  }

  void _startCampaignRounds() {
    final stage = campaignStage!;
    if (stage.rounds.isEmpty) {
      throw CampaignContentException(
        'Stage "${stage.id}" has no rounds to start.',
      );
    }

    roundDirector = RoundDirector(
      rounds: stage.rounds,
      onRoundStarted: _spawnCampaignRound,
      onStageCompleted: () => _finishCampaign(true),
    )..start();
  }

  void _spawnCampaignRound(StageRoundModel round) {
    for (final monster in monsters) {
      monster.removeFromParent();
    }
    monsters.clear();

    final stage = campaignStage!;
    for (final encounter in round.encounters) {
      final marker = _campaignSpawnMarkers[encounter.spawnMarker];
      if (marker == null) {
        throw CampaignContentException(
          'Stage "${stage.id}" round ${round.number} references missing Tiled spawn marker "${encounter.spawnMarker}".',
        );
      }
      final enemy = stage.enemyById(encounter.enemyId);
      if (enemy == null) {
        throw CampaignContentException(
          'Stage "${stage.id}" round ${round.number} references unknown enemy "${encounter.enemyId}".',
        );
      }

      for (var index = 0; index < encounter.count; index++) {
        const spacing = GameConstants.tileSize * 2;
        final offset = (index - (encounter.count - 1) / 2) * spacing;
        final monster = _createMonster(enemy, marker);
        monster.position = Vector2(marker.x + offset, marker.y);
        add(monster);
        monsters.add(monster);
      }
    }
  }

  void _finishCampaign(bool success) {
    if (hasShownDialog) return;
    hasShownDialog = true;
    roundDirector?.stop();
    onStageCompleted(success);
  }

  @override
  void onRemove() {
    roundDirector?.stop();
    super.onRemove();
  }

  void checkVictoryCondition() {
    if (hasShownDialog) return;
    if (character.isDead) {
      hasShownDialog = true;
      Future.delayed(const Duration(seconds: 1), () {
        character.velocity = Vector2.zero();
        onStageCompleted(false);
      });
    }
  }
}
