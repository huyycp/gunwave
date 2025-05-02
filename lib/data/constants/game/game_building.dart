import 'package:gunwave/data/constants/game/game_color.dart';

enum GameBuilding {

  blueTower('tower', GameColor.blue);

  final String name;
  final GameColor color;

  const GameBuilding(this.name, this.color);

  String get path => 'buildings/$name/${name}_${color.name}.png';
}

class GameBuildings {
  const GameBuildings._();
  static const GameBuildings instance = GameBuildings._();

  final name = 'building';

  final blueTower = GameBuilding.blueTower;
}