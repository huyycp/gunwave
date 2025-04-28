import 'package:gunwave/data/constants/game/game_character.dart';

enum GameMonster {
  torch('torch', GameColor.blue),;

  final String name;
  final GameColor color;

  const GameMonster(this.name, this.color); 

  String get path => 'factions/goblins/troops/$name/${color.name}/${name}_${color.name}.png';
}

class GameMonsters {
  const GameMonsters._();
  static const GameMonsters instance = GameMonsters._();

  final name = 'monster';

  final torch = GameMonster.torch;
}
