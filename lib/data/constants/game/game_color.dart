import 'dart:ui';

enum GameColor {
  red('red'),
  blue('blue'),
  yellow('yellow'),
  purple('purple');

  final String name;

  const GameColor(this.name);

  static Color get primary => const Color(0xFF1A2E53);
}