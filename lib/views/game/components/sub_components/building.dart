import 'package:flame/components.dart';
import 'package:gunwave/data/constants/game/game_building.dart';
import 'package:gunwave/views/game/gunwave.dart';

class Building extends SpriteComponent with HasGameRef<Gunwave> {
  Building({
    required this.building,
    required super.position,
    required super.size,
  });

  final GameBuilding building;

  @override
  Future<void> onLoad() async {
    sprite = Sprite(gameRef.images.fromCache(building.path));
    super.onLoad();
  }
}