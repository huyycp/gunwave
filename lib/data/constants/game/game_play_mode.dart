enum GamePlayMode {
  joystick,
  gesture,
  keyboard;

  bool get isJoystick => this == GamePlayMode.joystick;
  bool get isGesture => this == GamePlayMode.gesture;
  bool get isKeyboard => this == GamePlayMode.keyboard;
}