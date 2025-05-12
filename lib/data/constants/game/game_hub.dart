import 'package:gunwave/gen/assets.gen.dart';

class GameHubs {
  const GameHubs._(this.path);

  final String path;

  static const className = 'hubs';
  static final basePath = Assets.images.hub;

  static final values = [
    joystickKnob,
    joystickBackground,
  ];

  static final joystickKnob = GameHubs._(basePath.joystick.knob.path);
  static final joystickBackground = GameHubs._(basePath.joystick.background.path);
}