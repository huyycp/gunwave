import 'package:gunwave/gen/assets.gen.dart';

class GameBuildings {
  const GameBuildings._(this.name, this.path);

  final String name;
  final String path;

  static const className = 'building';
  static final basePath = Assets.images.buildings;

  static final values = [
    blueTower,
  ];

  static final GameBuildings blueTower = GameBuildings._(
    'tower_blue',
    basePath.tower.towerBlue.path,
  );
}