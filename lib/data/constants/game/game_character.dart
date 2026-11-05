import 'package:gunwave/gen/assets.gen.dart';

class GameCharacters {
  const GameCharacters._(this.name, this.path);

  final String name;
  final String path;

  static const className = 'character';
  static final basePath = Assets.images.factions.knights;

  static final values = [
    blueWarrior,
    redWarrior,
    yellowWarrior,
    purpleWarrior,
    blueArcher,
    redArcher,
    yellowArcher,
    purpleArcher,
    bluePawn,
    redPawn,
    yellowPawn,
    purplePawn,
  ];

  static final blueWarrior = GameCharacters._(
    'warrior_blue',
    basePath.warrior.blue.warriorBluePng.path,
  );

  static final redWarrior = GameCharacters._(
    'warrior_red',
    basePath.warrior.red.warriorRedPng.path,
  );

  static final yellowWarrior = GameCharacters._(
    'warrior_yellow',
    basePath.warrior.yellow.warriorYellowPng.path,
  );

  static final purpleWarrior = GameCharacters._(
    'warrior_purple',
    basePath.warrior.purple.warriorPurplePng.path,
  );

  static final blueArcher = GameCharacters._(
    'archer_blue',
    basePath.archer.blue.archerBluePng.path,
  );

  static final redArcher = GameCharacters._(
    'archer_red',
    basePath.archer.red.archerRedPng.path,
  );

  static final yellowArcher = GameCharacters._(
    'archer_yellow',
    basePath.archer.yellow.archerYellowPng.path,
  );

  static final purpleArcher = GameCharacters._(
    'archer_purple',
    basePath.archer.purple.archerPurlplePng.path,
  );

  static final bluePawn = GameCharacters._(
    'pawn_blue',
    basePath.pawn.blue.pawnBluePng.path,
  );

  static final redPawn = GameCharacters._(
    'pawn_red',
    basePath.pawn.red.pawnRedPng.path,
  );

  static final yellowPawn = GameCharacters._(
    'pawn_yellow',
    basePath.pawn.yellow.pawnYellowPng.path,
  );

  static final purplePawn = GameCharacters._(
    'pawn_purple',
    basePath.pawn.purple.pawnPurplePng.path,
  );
}
