import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:gunwave/data/constants/game/game_building.dart';
import 'package:gunwave/views/game/gunwave.dart';

class Building extends SpriteComponent with HasGameRef<Gunwave> {
  Building({
    required this.building,
    required super.position,
    required super.size,
    this.isCheckpoint = false,
  });

  final GameBuildings building;
  final bool isCheckpoint;

  final checkZone = RectangleHitbox(
    position: Vector2(0, 64 * 2 + 64 / 2),
    size: Vector2(64 * 2, 64 * 2 - 64 / 2),
  );

  @override
  Future<void> onLoad() async {
    sprite = Sprite(gameRef.images.fromCache(building.path));
    add(checkZone);
    super.onLoad();
  }
}