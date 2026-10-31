enum GameButtonState {
  enabled(''),
  hovered('hover'),
  pressed('pressed'),
  disabled('disabled');

  final String text;

  const GameButtonState(this.text);
}


enum GameButtonSize {
  small(''),
  medium('slide'),
  large('square');

  final String text;

  const GameButtonSize(this.text);
}