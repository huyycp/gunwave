import 'package:gunwave/data/constants/game/game_color.dart';

enum GameMonster {
  blueBarrel('barrel', GameColor.blue),
  redBarrel('barrel', GameColor.red),
  yellowBarrel('barrel', GameColor.yellow),
  purpleBarrel('barrel', GameColor.purple),

  blueTnt('tnt', GameColor.blue),
  redTnt('tnt', GameColor.red),
  yellowTnt('tnt', GameColor.yellow),
  purpleTnt('tnt', GameColor.purple),

  blueTorch('torch', GameColor.blue),
  redTorch('torch', GameColor.red),
  yellowTorch('torch', GameColor.yellow),
  purpleTorch('torch', GameColor.purple);

  final String name;
  final GameColor color;

  const GameMonster(this.name, this.color); 

  String get path => 'factions/monsters/$name/${color.name}/${name}_${color.name}.png';
}

class GameMonsters {
  const GameMonsters._();
  static const GameMonsters instance = GameMonsters._();

  final name = 'monster';

  final blueBarrel = GameMonster.blueBarrel;
  final redBarrel = GameMonster.redBarrel;
  final yellowBarrel = GameMonster.yellowBarrel;
  final purpleBarrel = GameMonster.purpleBarrel;

  final blueTnt = GameMonster.blueTnt;
  final redTnt = GameMonster.redTnt;
  final yellowTnt = GameMonster.yellowTnt;
  final purpleTnt = GameMonster.purpleTnt;

  final blueTorch = GameMonster.blueTorch;
  final redTorch = GameMonster.redTorch;
  final yellowTorch = GameMonster.yellowTorch;
  final purpleTorch = GameMonster.purpleTorch;
}
