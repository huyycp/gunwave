import 'package:gunwave/data/constants/game/game_character.dart';
import 'package:gunwave/data/constants/game/game_collision.dart';
import 'package:gunwave/data/constants/game/game_hub.dart';
import 'package:gunwave/data/constants/game/game_layer.dart';
import 'package:gunwave/data/constants/game/game_map.dart';
import 'package:gunwave/data/constants/game/game_monster.dart';
import 'package:gunwave/data/constants/game/game_trap.dart';

class GameConstants {
  GameConstants._();

  static const double tileSize = 64;

  static const double fps = 60;
  static double refreshRate = 1 / fps;
}

class GameComponents {
  GameComponents._();

  static const characters = GameCharacters.instance;
  static const monsters = GameMonsters.instance;
  static const maps = GameMaps.instance;
  static const layers = GameLayers.instance;
  static const colissions = GameCollisions.instance;
  static const hub = GameHubs.instance;
  static const trap = GameTraps.instance;
}

