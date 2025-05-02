import 'package:gunwave/data/constants/game/game_color.dart';

enum GameCharacter {
  blueArcher('archer', GameColor.blue),
  redArcher('archer', GameColor.red),
  yellowArcher('archer', GameColor.yellow),
  purpleArcher('archer', GameColor.purple),

  bluePawn('pawn', GameColor.blue),
  redPawn('pawn', GameColor.red),
  yellowPawn('pawn', GameColor.yellow),
  purplePawn('pawn', GameColor.purple),

  blueWarrior('warrior', GameColor.blue),
  redWarrior('warrior', GameColor.red),
  yellowWarrior('warrior', GameColor.yellow),
  purpleWarrior('warrior', GameColor.purple);

  final String name;
  final GameColor color;

  const GameCharacter(this.name, this.color); 

  String get path => 'factions/knights/$name/${color.name}/${name}_${color.name}.png';
}

class GameCharacters {
  const GameCharacters._();
  static const GameCharacters instance = GameCharacters._();

  final name = 'character';

  final blueArcher = GameCharacter.blueArcher;
  final redArcher = GameCharacter.redArcher;
  final yellowArcher = GameCharacter.yellowArcher;
  final purpleArcher = GameCharacter.purpleArcher;

  final bluePawn = GameCharacter.bluePawn;
  final redPawn = GameCharacter.redPawn;
  final yellowPawn = GameCharacter.yellowPawn;
  final purplePawn = GameCharacter.purplePawn;

  final blueWarrior = GameCharacter.blueWarrior;
  final redWarrior = GameCharacter.redWarrior;
  final yellowWarrior = GameCharacter.yellowWarrior;
  final purpleWarrior = GameCharacter.purpleWarrior;
}