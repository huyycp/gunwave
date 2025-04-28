import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:gunwave/data/constants/game/game_constants.dart';
import 'package:gunwave/views/game/gunwave.dart';

class AttachButton extends SpriteComponent with HasGameRef<Gunwave>, TapCallbacks, DoubleTapCallbacks {
  AttachButton({
    required this.onAttack,
    super.position,
    super.size,
  });

  final void Function(bool attack) onAttack;

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());

    sprite = Sprite(game.images.fromCache(GameComponents.hub.joystickKnob.path));
    
    priority = 1;

    await super.onLoad();
  }

  @override
  void onTapUp(TapUpEvent event) {
    onAttack(false);
    super.onTapUp(event);
  }

  @override
  void onTapDown(TapDownEvent event) {
    onAttack(true);
    super.onTapDown(event);
  }
}