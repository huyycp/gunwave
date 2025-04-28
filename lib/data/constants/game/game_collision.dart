enum GameCollision {
  block('block');

  final String name;

  const GameCollision(this.name);
}

class GameCollisions {
  const GameCollisions._();
  static const GameCollisions instance = GameCollisions._();

  final block = GameCollision.block;
}