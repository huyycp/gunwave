import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/text.dart';
import 'package:flutter/foundation.dart' show ValueChanged, VoidCallback;
import 'package:flutter/painting.dart' show EdgeInsets;
import 'package:gunwave/data/constants/game/game_button.dart';
import 'package:gunwave/data/constants/game/game_hud_style.dart';
import 'package:gunwave/data/constants/game/game_map.dart';
import 'package:gunwave/data/constants/game/game_menu_style.dart';
import 'package:gunwave/data/constants/game/game_ui.dart';
import 'package:gunwave/data/models/character_model.dart';
import 'package:gunwave/data/models/monster_model.dart';
import 'package:gunwave/views/game/ui/bitmap_font.dart';
import 'package:gunwave/views/game/ui/components/asset_button_component.dart';
import 'package:gunwave/views/game/ui/components/asset_panel_component.dart';
import 'package:gunwave/views/game/ui/responsive_ui_layout.dart';
import 'package:gunwave/views/rpg_ui/rpg_menu_models.dart';

/// Shared sprite, bitmap-text, panel, and responsive layout helpers for menus.
abstract class RpgMenuScene extends PositionComponent
    with HasGameReference<FlameGame> {
  RpgMenuScene({
    required this.snapshot,
    required this.labels,
    required this.actions,
    required this.safeAreaInsets,
    required this.onNavigate,
    super.priority,
  });

  final RpgMenuSnapshot snapshot;
  final RpgMenuLabels labels;
  final RpgMenuActions actions;
  final EdgeInsets safeAreaInsets;
  final ValueChanged<RpgMenuPage> onNavigate;

  late final UiBitmapFontRenderer font;
  late final SpriteComponent background;
  late final RectangleComponent shade;
  late final Sprite panelSprite;
  late ResponsiveUiLayout responsiveLayout;
  bool _sceneArtLoaded = false;
  bool _contentLoaded = false;

  Rect get contentBounds => responsiveLayout.contentBounds;
  double get uiScale => responsiveLayout.scale;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = game.size;
    font = await UiBitmapFont.load(game.images);
    final backgroundImage = await game.images.load(
      _cachePath(game.images, GameMaps.forest.imagePath),
    );
    final panelImage = await game.images.load(
      _cachePath(game.images, GameUiAssets.panel.path),
    );
    background = SpriteComponent(
      sprite: Sprite(backgroundImage),
      priority: -100,
      anchor: Anchor.topLeft,
    );
    shade = RectangleComponent(
      paint: Paint()..color = const Color(0x66080C12),
      priority: -90,
      anchor: Anchor.topLeft,
    );
    panelSprite = Sprite(panelImage);
    addAll([background, shade]);
    _sceneArtLoaded = true;
    await loadScene();
    _contentLoaded = true;
    if (size.x > 0 && size.y > 0) onGameResize(size);
  }

  Future<void> loadScene();

  void layoutScene();

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    responsiveLayout = ResponsiveUiLayout(
      viewportSize: size,
      safeAreaInsets: safeAreaInsets,
    );
    if (!_sceneArtLoaded) return;
    final imageSize = background.sprite!.srcSize;
    final scale = math.max(size.x / imageSize.x, size.y / imageSize.y);
    background.size = imageSize;
    background.scale = Vector2.all(scale);
    background.position = Vector2(
      (size.x - imageSize.x * scale) / 2,
      (size.y - imageSize.y * scale) / 2,
    );
    shade.size = size;
    if (_contentLoaded) layoutScene();
  }

  AssetPanelComponent addPanel(Vector2 panelSize, {Vector2? position}) {
    final panel = AssetPanelComponent(
      sprite: panelSprite,
      size: panelSize,
      position: position,
      borders: const NineSliceBorders(
        left: GameMenuStyle.panelBorderInset,
        top: GameMenuStyle.panelBorderInset,
        right: GameMenuStyle.panelBorderInset,
        bottom: GameMenuStyle.panelBorderInset,
      ),
    );
    add(panel);
    return panel;
  }

  TextComponent<SpriteFontRenderer> addText(
    String text, {
    double scale = 1,
    Anchor anchor = Anchor.center,
    Vector2? position,
  }) {
    final component = TextComponent<SpriteFontRenderer>(
      text: font.sanitize(text),
      textRenderer: font,
      anchor: anchor,
      position: position,
      scale: Vector2.all(scale),
    );
    add(component);
    return component;
  }

  Future<AssetButtonComponent> addButton(
    String text,
    VoidCallback onPressed, {
    required Vector2 buttonSize,
    Vector2? position,
    Anchor anchor = Anchor.center,
    GameButtonSize assetSize = GameButtonSize.medium,
    bool enabled = true,
  }) async {
    final component = await AssetButtonComponent.load(
      game.images,
      buttonSize: assetSize,
      size: buttonSize,
      hitAreaSize: Vector2.all(GameHudStyle.minimumTouchSize),
      position: position,
      anchor: anchor,
      enabled: enabled,
      label: text,
      labelRenderer: font,
      onPressed: onPressed,
    );
    add(component);
    return component;
  }

  Future<SpriteAnimationComponent?> loadHeroPreview(
    CharacterModel? character, {
    required Vector2 size,
    Vector2? position,
  }) async {
    final asset = character?.character;
    if (asset == null) return null;
    final image = await game.images.load(_cachePath(game.images, asset.path));
    final preview = SpriteAnimationComponent(
      animation: SpriteAnimation.fromFrameData(
        image,
        SpriteAnimationData.sequenced(
          amount: GameMenuStyle.heroIdleFrameCount,
          stepTime: GameMenuStyle.previewFrameDuration,
          textureSize: Vector2.all(GameMenuStyle.spriteFrameSize),
          loop: true,
        ),
      ),
      size: size,
      position: position,
      anchor: Anchor.center,
    );
    add(preview);
    return preview;
  }

  Future<SpriteAnimationComponent?> loadMonsterPreview(
    MonsterModel? monster, {
    required Vector2 size,
    Vector2? position,
  }) async {
    final asset = monster?.monster;
    if (asset == null) return null;
    final image = await game.images.load(_cachePath(game.images, asset.path));
    final preview = SpriteAnimationComponent(
      animation: SpriteAnimation.fromFrameData(
        image,
        SpriteAnimationData.sequenced(
          amount: GameMenuStyle.monsterIdleFrameCount,
          stepTime: GameMenuStyle.previewFrameDuration,
          textureSize: Vector2.all(GameMenuStyle.spriteFrameSize),
          loop: true,
        ),
      ),
      size: size,
      position: position,
      anchor: Anchor.center,
    );
    add(preview);
    return preview;
  }
}

String _cachePath(Images images, String assetPath) =>
    assetPath.startsWith(images.prefix)
    ? assetPath.substring(images.prefix.length)
    : assetPath;
