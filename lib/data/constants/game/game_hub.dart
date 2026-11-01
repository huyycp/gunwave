import 'package:gunwave/gen/assets.gen.dart';

class GameHubs {
  const GameHubs._(this.path);

  final String path;

  static const className = 'hubs';
  static final basePath = Assets.images.hub;

  static final values = [
    joystickKnob,
    joystickBackground,
    attackButton,
    attackButtonPressed,
  ];

  static final joystickKnob = GameHubs._(basePath.joystick.knob.path);
  static final joystickBackground = GameHubs._(
    basePath.joystick.background.path,
  );
  static final attackButton = GameHubs._(
    Assets.images.ui.buttons.buttonRed.path,
  );
  static final attackButtonPressed = GameHubs._(
    Assets.images.ui.buttons.buttonRedPressed.path,
  );
}
