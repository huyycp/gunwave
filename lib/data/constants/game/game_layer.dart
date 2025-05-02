enum GameLayer {
  background('background'),
  spawnPoints('spawn_points'),
  collisions('collisions'),
  buildings('buildings'),;

  final String name;

  const GameLayer(this.name);
}

class GameLayers{
  const GameLayers._();
  static const GameLayers instance = GameLayers._();

  final background = GameLayer.background;
  final spawnPoints = GameLayer.spawnPoints;
  final collisions = GameLayer.collisions;
  final buildings = GameLayer.buildings;
}