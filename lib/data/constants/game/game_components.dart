import 'package:gunwave/data/constants/game/game_building.dart';
import 'package:gunwave/data/constants/game/game_character.dart';
import 'package:gunwave/data/constants/game/game_effect.dart';
import 'package:gunwave/data/constants/game/game_hub.dart';
import 'package:gunwave/data/constants/game/game_map.dart';
import 'package:gunwave/data/constants/game/game_monster.dart';

class GameComponents {
  const GameComponents._();

  static final values = [
    GameComponents.character,
  ];

  static const character = GameCharacters.className;
  static const monster = GameMonsters.className;
  static const map = GameMaps.className;
  static const hub = GameHubs.className;
  static const building = GameBuildings.className;
  static const effect = GameEffects.className;
}