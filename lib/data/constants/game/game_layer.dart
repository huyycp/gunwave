class GameLayers{
  const GameLayers._(this.name);

  final String name;

  static final values = [
    background,
    spawnPoints,
    collisions,
    buildings,
  ];

  static const background = GameLayers._('background');
  static const spawnPoints = GameLayers._('spawn_points');
  static const collisions = GameLayers._('collisions');
  static const buildings = GameLayers._('buildings');
}