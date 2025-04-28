enum GameHub {
  joystickKnob('hub/joystick/knob.png'),
  joystickBackground('hub/joystick/background.png');

  final String path;

  const GameHub(this.path);
}

class GameHubs {
  const GameHubs._();
  static const GameHubs instance = GameHubs._();


  final joystickKnob = GameHub.joystickKnob;
  final joystickBackground = GameHub.joystickBackground;
}