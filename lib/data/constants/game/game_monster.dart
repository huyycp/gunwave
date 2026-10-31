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
    'barrel_blue',
    basePath.barrel.blue.barrelBluePng.path,
  );

  static final redBarrel = GameMonsters._(
    'barrel_red',
    basePath.barrel.red.barrelRedPng.path,
  );
  
  static final yellowBarrel = GameMonsters._(
    'barrel_yellow',
    basePath.barrel.yellow.barrelYellowPng.path,
  );
  
  static final purpleBarrel = GameMonsters._(
    'barrel_purple',
    basePath.barrel.purple.barrelPurplePng.path,
  );

  static final blueTnt = GameMonsters._(
    'tnt_blue',
    basePath.tnt.blue.tntBluePng.path,
  );
  
  static final redTnt = GameMonsters._(
    'tnt_red',
    basePath.tnt.red.tntRedPng.path,
  );
  
  static final yellowTnt = GameMonsters._(
    'tnt_yellow',
    basePath.tnt.yellow.tntYellowPng.path,
  );
  
  static final purpleTnt = GameMonsters._(
    'tnt_purple',
    basePath.tnt.purple.tntPurplePng.path,
  );

  static final blueTorch = GameMonsters._(
    'torch_blue',
    basePath.torch.blue.torchBluePng.path,
  );
  
  static final redTorch = GameMonsters._(
    'torch_red',
    basePath.torch.red.torchRedPng.path,
  );
  
  static final yellowTorch = GameMonsters._(
    'torch_yellow',
    basePath.torch.yellow.torchYellowPng.path,
  );
  
  static final purpleTorch = GameMonsters._(
    'torch_purple',
    basePath.torch.purple.torchPurplePng.path,
  );
}
