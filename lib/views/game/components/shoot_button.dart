import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:gunwave/views/game/pixel_adventure.dart';

class ShootButton extends SpriteComponent with HasGameRef<PixelAdventure>, TapCallbacks {
  ShootButton({
    required this.onShoot,
    super.position,
    super.size,
  });

  final Function onShoot;

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());

    sprite = Sprite(game.images.fromCache('hub/joystick/knob.png'));
    
    priority = 1;

    await super.onLoad();
  }

  @override
  void onTapUp(TapUpEvent event) {
    onShoot();
    super.onTapUp(event);
  }
}