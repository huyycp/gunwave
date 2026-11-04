import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/data/constants/game/game_ui.dart';
import 'package:gunwave/views/game/ui/components/asset_progress_bar_component.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWithFlameGame('progress value is normalized and resizable', (game) async {
    final assetPaths = [
      GameUiAssets.progressFrame.path,
      GameUiAssets.progressBackground.path,
      GameUiAssets.progressFill.path,
    ];
    final images = await Future.wait(
      assetPaths.map((path) async {
        final key = path.startsWith(game.images.prefix)
            ? path.substring(game.images.prefix.length)
            : path;
        return game.images.load(key);
      }),
    );
    final bar = AssetProgressBarComponent(
      frameSprite: Sprite(images[0]),
      backgroundSprite: Sprite(images[1]),
      fillSprite: Sprite(images[2]),
      size: Vector2(180, 32),
      value: .4,
    );
    await game.ensureAdd(bar);

    expect(bar.value, .4);
    bar.value = 2;
    expect(bar.value, 1);
    bar.value = double.nan;
    expect(bar.value, 0);
    bar.size = Vector2(360, 44);
    expect(bar.size.x, 360);
    expect(bar.size.y, 44);
  });
}
