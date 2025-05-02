enum GameTrap {
  fire('fire');

  final String text;
  const GameTrap(this.text);

  String get path => 'effects/$text/$text.png';
}

class GameTraps {
  const GameTraps._();
  static const GameTraps instance = GameTraps._();

  final name = 'trap';

  final fire = GameTrap.fire;
}