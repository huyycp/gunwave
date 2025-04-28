enum GameCharacter {
  warrior('warrior', GameColor.blue),;

  final String name;
  final GameColor color;

  const GameCharacter(this.name, this.color); 

  String get path => 'factions/knights/troops/$name/${color.name}/${name}_${color.name}.png';
}

class GameCharacters {
  const GameCharacters._();
  static const GameCharacters instance = GameCharacters._();

  final name = 'character';

  final warrior = GameCharacter.warrior;
}

enum GameColor {
  red('red'),
  blue('blue'),
  yellow('yellow'),
  purple('purple');

  final String name;

  const GameColor(this.name);
}