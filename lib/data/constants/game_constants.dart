enum GameLayers {
  background('background'),
  spawnPoints('spawn_points'),
  collisions('collisions'),;

  final String name;

  const GameLayers(this.name);
}

/// Split into [actor], [item], [trap], [collision]
enum GameObjects {
  character,
  enemy,
  platform,
  fruit,
  saw,
  unknown,
}

enum GameComponents {
  joystickKnob('hub/joystick/knob.png'),
  joystickBackground('hub/joystick/background.png');

  final String path;

  const GameComponents(this.path);
}

enum GameWorlds {
  level1('level_1', horizontalTile: 40, verticalTile: 23),
  level2('level_2', horizontalTile: 60, verticalTile: 43);

  final String name;
  final int horizontalTile;
  final int verticalTile;

  double get width => horizontalTile * GameConstants.tileSize;
  double get height => verticalTile * GameConstants.tileSize;

  const GameWorlds(this.name, {this.horizontalTile = 0, this.verticalTile = 0});
}

class GameConstants {
  static const double tileSize = 16;
}