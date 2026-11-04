import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/data/constants/game/game_hud_style.dart';
import 'package:gunwave/views/game/ui/components/asset_panel_component.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWithFlameGame('nine-slice panel supports custom sizes', (game) async {
    final panel = await AssetPanelComponent.load(
      game.images,
      size: Vector2(280, 160),
    );
    await game.ensureAdd(panel);

    expect(panel.size.x, 280);
    expect(panel.size.y, 160);
    expect(panel.nineTileBox!.center.left, GameHudStyle.panelBorderInset);

    panel.size = Vector2(520, 240);
    expect(panel.size.x, 520);
    expect(panel.size.y, 240);
    expect(panel.nineTileBox!.center.left, GameHudStyle.panelBorderInset);
  });
}
