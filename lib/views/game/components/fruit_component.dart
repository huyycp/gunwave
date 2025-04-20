import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:gunwave/views/game/components/character.dart';
import 'package:gunwave/views/game/components/component_hitbox.dart';
import 'package:gunwave/views/game/pixel_adventure.dart';

class FruitComponent extends SpriteAnimationComponent with HasGameRef<PixelAdventure>, CollisionCallbacks {
  FruitComponent({
    required this.fruit,
    super.position,
    super.size,
    this.frameAmount = 17,
    this.stepTime = 0.1,
    this.hitbox = const ComponentHitbox(
      offsetX: 8,
      offsetY: 8,
      width: 16,
      height: 16,
    ),
  });

  final String fruit;
  final int frameAmount;
  final double stepTime;
  final ComponentHitbox hitbox;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    priority = -1;
    animation = getFruitSprite();

    add(RectangleHitbox(
      size: Vector2(hitbox.width, hitbox.height),
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      collisionType: CollisionType.passive,
    ));
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Character) {
      animation = getCollectedSprite();
      Future.delayed(Duration(milliseconds: (stepTime * frameAmount).floor()), () {
        removeFromParent();
      });
    }
    super.onCollision(intersectionPoints, other);
  }


  SpriteAnimation getFruitSprite() {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('items/fruits/$fruit.png'),
      SpriteAnimationData.sequenced(
        amount: frameAmount,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
        loop: true,
      ),
    );
  }

  SpriteAnimation getCollectedSprite() {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('items/fruits/collected.png'),
      SpriteAnimationData.sequenced(
        amount: 6,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
        loop: false,
      ),
    );
  }
}