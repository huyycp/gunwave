import 'package:gunwave/gen/assets.gen.dart';

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

/// Resolves each Flame button state to a checked-in Tiny Swords sprite.
class GameButtonAssets {
  const GameButtonAssets({
    required this.normal,
    required this.hovered,
    required this.pressed,
    required this.disabled,
  });

  final AssetGenImage normal;
  final AssetGenImage hovered;
  final AssetGenImage pressed;
  final AssetGenImage disabled;

  static GameButtonAssets forSize(GameButtonSize size) => switch (size) {
    GameButtonSize.small => GameButtonAssets(
      normal: Assets.images.ui.buttons.button,
      hovered: Assets.images.ui.buttons.buttonHover,
      pressed: Assets.images.ui.buttons.buttonPressed,
      disabled: Assets.images.ui.buttons.buttonDisabled,
    ),
    GameButtonSize.medium => GameButtonAssets(
      normal: Assets.images.ui.buttons.buttonSlide,
      hovered: Assets.images.ui.buttons.buttonSlideHover,
      pressed: Assets.images.ui.buttons.buttonSlidePressed,
      disabled: Assets.images.ui.buttons.buttonSlideDisabled,
    ),
    GameButtonSize.large => GameButtonAssets(
      normal: Assets.images.ui.buttons.buttonSquare,
      hovered: Assets.images.ui.buttons.buttonSquareHover,
      pressed: Assets.images.ui.buttons.buttonSquarePressed,
      disabled: Assets.images.ui.buttons.buttonSquareDisabled,
    ),
  };
}
