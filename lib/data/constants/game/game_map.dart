import 'package:gunwave/data/constants/game/game_constants.dart';

enum GameMap {
  forest('forest', horizontalTile: 40, verticalTile: 20);

  final String name;
  final int horizontalTile;
  final int verticalTile;

  double get width => horizontalTile * GameConstants.tileSize;
  double get height => verticalTile * GameConstants.tileSize;

  const GameMap(this.name, {this.horizontalTile = 0, this.verticalTile = 0});
}

class GameMaps {
  const GameMaps._();
  static const GameMaps instance = GameMaps._();

  final easy = GameMap.forest;
}