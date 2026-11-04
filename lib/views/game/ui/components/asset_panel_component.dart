import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:gunwave/data/constants/game/game_hud_style.dart';
import 'package:gunwave/data/constants/game/game_ui.dart';

/// Fixed source-image borders used by Flame's nine-slice renderer.
class NineSliceBorders {
  const NineSliceBorders({
    this.left = GameHudStyle.panelBorderInset,
    this.top = GameHudStyle.panelBorderInset,
    this.right = GameHudStyle.panelBorderInset,
    this.bottom = GameHudStyle.panelBorderInset,
  });

  final double left;
  final double top;
  final double right;
  final double bottom;
}

/// A resizable panel backed by the Tiny Swords carved panel sprite.
class AssetPanelComponent extends NineTileBoxComponent with HasVisibility {
  AssetPanelComponent({
    required Sprite sprite,
    required Vector2 size,
    NineSliceBorders borders = const NineSliceBorders(),
    super.position,
    super.anchor,
    super.priority,
  }) : super(
         size: size,
         nineTileBox: NineTileBox.withGrid(
           sprite,
           leftWidth: borders.left,
           topHeight: borders.top,
           rightWidth: borders.right,
           bottomHeight: borders.bottom,
         ),
       );

  /// Loads the shared panel art through Flame's image cache.
  static Future<AssetPanelComponent> load(
    Images images, {
    required Vector2 size,
    Vector2? position,
    Anchor? anchor,
    NineSliceBorders borders = const NineSliceBorders(),
  }) async {
    final assetPath = GameUiAssets.panel.path;
    final image = await images.load(_cachePath(images, assetPath));
    return AssetPanelComponent(
      sprite: Sprite(image),
      size: size,
      position: position,
      anchor: anchor,
      borders: borders,
    );
  }
}

String _cachePath(Images images, String assetPath) {
  return assetPath.startsWith(images.prefix)
      ? assetPath.substring(images.prefix.length)
      : assetPath;
}
