import 'dart:ui' show Image, Rect;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/data/constants/game/game_ui.dart';
import 'package:gunwave/views/game/ui/components/asset_progress_bar_component.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWithFlameGame('progress value is normalized and resizable', (game) async {
    final smallBase = await _loadImage(game, GameUiAssets.smallBarBase.path);
    final smallFill = await _loadImage(game, GameUiAssets.smallBarFill.path);
    final bigBase = await _loadImage(game, GameUiAssets.bigBarBase.path);
    final bigFill = await _loadImage(game, GameUiAssets.bigBarFill.path);
    final bar = AssetProgressBarComponent(
      frameSprite: _crop(smallBase, GameUiAssets.smallBarFrameCrop),
      fillSprite: _crop(smallFill, GameUiAssets.smallBarFillCrop),
      capWidth: GameUiAssets.smallBarCapWidth,
      size: Vector2(180, 32),
      value: .4,
    );
    final bossBar = AssetProgressBarComponent(
      frameSprite: _crop(bigBase, GameUiAssets.bigBarFrameCrop),
      fillSprite: _crop(bigFill, GameUiAssets.bigBarFillCrop),
      capWidth: GameUiAssets.bigBarCapWidth,
      size: Vector2(252, 17),
      value: .5,
    );
    await game.ensureAdd(bar);
    await game.ensureAdd(bossBar);

    expect(bar.value, .4);
    bar.value = 2;
    expect(bar.value, 1);
    bar.value = double.nan;
    expect(bar.value, 0);
    bar.size = Vector2(360, 44);
    expect(bar.size.x, 360);
    expect(bar.size.y, 44);
    expect(bossBar.value, .5);
    expect(bossBar.size.x, 252);
    expect(bossBar.size.y, 17);
  });
}

Future<Image> _loadImage(FlameGame game, String path) {
  final key = path.startsWith(game.images.prefix)
      ? path.substring(game.images.prefix.length)
      : path;
  return game.images.load(key);
}

Sprite _crop(Image image, Rect rect) => Sprite(
  image,
  srcPosition: Vector2(rect.left, rect.top),
  srcSize: Vector2(rect.width, rect.height),
);
