import 'dart:ui' show FilterQuality;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:gunwave/data/constants/game/game_hud_style.dart';
import 'package:gunwave/data/constants/game/game_hub.dart';

/// Pixel-art attack target that mirrors each touch press into combat input.
class AttachButton extends SpriteComponent
    with HasGameRef<FlameGame>, TapCallbacks, DoubleTapCallbacks {
  /// Creates a touch target using the shared attack-button size by default.
  AttachButton({required this.onAttack, super.position, Vector2? size})
    : super(size: size ?? Vector2.all(GameHudStyle.touchAttackSize));

  final void Function(bool attack) onAttack;
  late final Sprite _normalSprite;
  late final Sprite _pressedSprite;
  bool _isPressed = false;

  /// Exposes the current visual state alongside the attack callback state.
  bool get isPressed => _isPressed;

  /// Loads the normal and pressed frame sprites from Flame's image cache.
  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());

    _normalSprite = Sprite(game.images.fromCache(GameHubs.attackButton.path));
    _pressedSprite = Sprite(
      game.images.fromCache(GameHubs.attackButtonPressed.path),
    );
    sprite = _normalSprite;
    paint.filterQuality = FilterQuality.none;

    priority = 1;

    await super.onLoad();
  }

  @override
  void onTapUp(TapUpEvent event) {
    _setPressed(false);
    super.onTapUp(event);
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _setPressed(false);
    super.onTapCancel(event);
  }

  @override
  void onTapDown(TapDownEvent event) {
    _setPressed(true);
    super.onTapDown(event);
  }

  /// Selects the matching asset frame and forwards the state to combat input.
  void _setPressed(bool value) {
    if (_isPressed == value) return;
    _isPressed = value;
    sprite = value ? _pressedSprite : _normalSprite;
    onAttack(value);
  }
}
