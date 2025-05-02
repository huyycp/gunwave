enum GameCollision {
  boundary('boundary');

  final String name;

  const GameCollision(this.name);
}

class GameCollisions {
  const GameCollisions._();
  static const GameCollisions instance = GameCollisions._();

  final boundary = GameCollision.boundary;
}