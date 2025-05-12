import 'package:gunwave/gen/assets.gen.dart';

class GameEffects {
  const GameEffects._(this.name, this.path);

  final String name;
  final String path;

  static const className = 'effects';
  static final basePath = Assets.images.effects;

  static final values = [
    explosion,
    fire,
  ];

  static final explosion = GameEffects._(
    'explosion',
    basePath.explosion.explosionsPng.path,
  );

  static final fire = GameEffects._(
    'fire',
    basePath.fire.firePng.path,
  );
}