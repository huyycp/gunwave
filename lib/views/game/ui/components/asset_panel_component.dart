import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:gunwave/data/constants/game/game_ui.dart';

/// Fixed source-image borders used by Flame's nine-slice renderer.
class NineSliceBorders {
  const NineSliceBorders({
    this.left = 64,
    this.top = 64,
    this.right = 64,
    this.bottom = 64,
  });

  // Tiny Swords' 192px carved panel uses a 64px corner grid.
  static const carvedPanel = NineSliceBorders();
  // The 64px square and 192x64 slide buttons use their own corner geometry.
  static const smallButton = NineSliceBorders(
    left: 16,
    top: 16,
    right: 16,
    bottom: 16,
  );
  static const slideButton = NineSliceBorders(
    left: 32,
    top: 12,
    right: 32,
    bottom: 12,
  );
  static const squareButton = NineSliceBorders(
    left: 48,
    top: 48,
    right: 48,
    bottom: 48,
  );

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
    NineSliceBorders borders = NineSliceBorders.carvedPanel,
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
    NineSliceBorders borders = NineSliceBorders.carvedPanel,
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
