import 'package:gunwave/gen/assets.gen.dart';

class GameMonsters {
  const GameMonsters._(this.name, this.path);

  final String name;
  final String path;
  
  static const className = 'monster';
  static final basePath = Assets.images.factions.monsters;

  static final values = [
    blueBarrel,
    redBarrel,
    yellowBarrel,
    purpleBarrel,
    blueTnt,
    redTnt,
    yellowTnt,
    purpleTnt,
    blueTorch,
    redTorch,
    yellowTorch,
    purpleTorch,
  ];

  static final blueBarrel = GameMonsters._(
    'barrel',
    basePath.barrel.blue.barrelBluePng.path,
  );

  static final redBarrel = GameMonsters._(
    'barrel',
    basePath.barrel.red.barrelRedPng.path,
  );
  
  static final yellowBarrel = GameMonsters._(
    'barrel',
    basePath.barrel.yellow.barrelYellowPng.path,
  );
  
  static final purpleBarrel = GameMonsters._(
    'barrel',
    basePath.barrel.purple.barrelPurplePng.path,
  );

  static final blueTnt = GameMonsters._(
    'tnt',
    basePath.tnt.blue.tntBluePng.path,
  );
  
  static final redTnt = GameMonsters._(
    'tnt',
    basePath.tnt.red.tntRedPng.path,
  );
  
  static final yellowTnt = GameMonsters._(
    'tnt',
    basePath.tnt.yellow.tntYellowPng.path,
  );
  
  static final purpleTnt = GameMonsters._(
    'tnt',
    basePath.tnt.purple.tntPurplePng.path,
  );

  static final blueTorch = GameMonsters._(
    'torch',
    basePath.torch.blue.torchBluePng.path,
  );
  
  static final redTorch = GameMonsters._(
    'torch',
    basePath.torch.red.torchRedPng.path,
  );
  
  static final yellowTorch = GameMonsters._(
    'torch',
    basePath.torch.yellow.torchYellowPng.path,
  );
  
  static final purpleTorch = GameMonsters._(
    'torch',
    basePath.torch.purple.torchPurplePng.path,
  );
}
