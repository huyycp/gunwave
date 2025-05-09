import 'package:gunwave/gen/assets.gen.dart';

class GameMaps {
  const GameMaps._(this.name, this.path, this.imagePath);

  final String name;
  
  /// Path to tmx
  final String path;

  /// Path to png
  final String imagePath;

  static const className = 'maps';
  static const basePath = Assets.tiles;

  static final values = [
    forest,
  ];

  static final forest = GameMaps._('forest', basePath.forestTmx, basePath.forestPng.path);
  static final loading = GameMaps._('loading', basePath.loading, '');
  static final background = GameMaps._('background', basePath.background, '');
}