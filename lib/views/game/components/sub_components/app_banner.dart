import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/image_composition.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gunwave/data/constants/game/game_color.dart';
import 'package:gunwave/data/constants/game/game_ui.dart';

class AppBanner extends PositionComponent with HasGameRef<FlameGame> {
  AppBanner({
    required this.banner,
    this.text = '',
    this.xCount = 1, // Default to 1 horizontal middle section
    this.yCount = 1, // Default to 1 vertical middle section
  });

  final GameBanners banner;
  final String text;
  final int xCount; // Number of horizontal middle sections
  final int yCount; // Number of vertical middle sections

  // 9-slice size constants
  final sliceSize = 64.0; // Each slice is 64x64

  @override
  Future<void> onLoad() async {
    try {
      game.images.prefix = '';
      await(game.images.load(banner.path));

      final spriteSheet = game.images.fromCache(banner.path);

      // Calculate total size based on slices and counts
      size = Vector2(
        sliceSize * (2 + xCount), // 2 edges + xCount center pieces
        sliceSize * (2 + yCount), // 2 edges + yCount center pieces
      );

      position = Vector2(
        (gameRef.size.x - size.x) / 2,
        (gameRef.size.y - size.y) / 2,
      );

      await _createNineSliceBanner(spriteSheet);

      if (text.isNotEmpty) {
        _addTextComponent();
      }
    } catch (e) {
      debugPrint('Error loading banner: $e');
    }

    return super.onLoad();
  }

  Future<void> _createNineSliceBanner(Image spriteSheet) async {
    // Extract all 9 slices from the sprite sheet
    // Corners (4)
    final topLeftSprite = Sprite(spriteSheet, srcPosition: Vector2(0, 0), srcSize: Vector2(sliceSize, sliceSize));
    final topRightSprite = Sprite(spriteSheet, srcPosition: Vector2(sliceSize * 2, 0), srcSize: Vector2(sliceSize, sliceSize));
    final bottomLeftSprite = Sprite(spriteSheet, srcPosition: Vector2(0, sliceSize * 2), srcSize: Vector2(sliceSize, sliceSize));
    final bottomRightSprite = Sprite(spriteSheet, srcPosition: Vector2(sliceSize * 2, sliceSize * 2), srcSize: Vector2(sliceSize, sliceSize));

    // Edges (4)
    final topEdgeSprite = Sprite(spriteSheet, srcPosition: Vector2(sliceSize, 0), srcSize: Vector2(sliceSize, sliceSize));
    final leftEdgeSprite = Sprite(spriteSheet, srcPosition: Vector2(0, sliceSize), srcSize: Vector2(sliceSize, sliceSize));
    final rightEdgeSprite = Sprite(spriteSheet, srcPosition: Vector2(sliceSize * 2, sliceSize), srcSize: Vector2(sliceSize, sliceSize));
    final bottomEdgeSprite = Sprite(spriteSheet, srcPosition: Vector2(sliceSize, sliceSize * 2), srcSize: Vector2(sliceSize, sliceSize));

    // Center (1)
    final centerSprite = Sprite(spriteSheet, srcPosition: Vector2(sliceSize, sliceSize), srcSize: Vector2(sliceSize, sliceSize));

    // 1. Add four corners
    // Top-left corner
    add(SpriteComponent(
      sprite: topLeftSprite,
      position: Vector2(0, 0),
      size: Vector2(sliceSize, sliceSize),
    ));

    // Top-right corner
    add(SpriteComponent(
      sprite: topRightSprite,
      position: Vector2(sliceSize * (1 + xCount), 0),
      size: Vector2(sliceSize, sliceSize),
    ));

    // Bottom-left corner
    add(SpriteComponent(
      sprite: bottomLeftSprite,
      position: Vector2(0, sliceSize * (1 + yCount)),
      size: Vector2(sliceSize, sliceSize),
    ));

    // Bottom-right corner
    add(SpriteComponent(
      sprite: bottomRightSprite,
      position: Vector2(sliceSize * (1 + xCount), sliceSize * (1 + yCount)),
      size: Vector2(sliceSize, sliceSize),
    ));

    // 2. Add edges
    // Top edge (repeats horizontally)
    for (int x = 0; x < xCount; x++) {
      add(SpriteComponent(
        sprite: topEdgeSprite,
        position: Vector2(sliceSize * (1 + x), 0),
        size: Vector2(sliceSize, sliceSize),
      ));
    }

    // Bottom edge (repeats horizontally)
    for (int x = 0; x < xCount; x++) {
      add(SpriteComponent(
        sprite: bottomEdgeSprite,
        position: Vector2(sliceSize * (1 + x), sliceSize * (1 + yCount)),
        size: Vector2(sliceSize, sliceSize),
      ));
    }

    // Left edge (repeats vertically)
    for (int y = 0; y < yCount; y++) {
      add(SpriteComponent(
        sprite: leftEdgeSprite,
        position: Vector2(0, sliceSize * (1 + y)),
        size: Vector2(sliceSize, sliceSize),
      ));
    }

    // Right edge (repeats vertically)
    for (int y = 0; y < yCount; y++) {
      add(SpriteComponent(
        sprite: rightEdgeSprite,
        position: Vector2(sliceSize * (1 + xCount), sliceSize * (1 + y)),
        size: Vector2(sliceSize, sliceSize),
      ));
    }

    // 3. Add center pieces (repeats in both directions)
    for (int y = 0; y < yCount; y++) {
      for (int x = 0; x < xCount; x++) {
        add(SpriteComponent(
          sprite: centerSprite,
          position: Vector2(sliceSize * (1 + x), sliceSize * (1 + y)),
          size: Vector2(sliceSize, sliceSize),
        ));
      }
    }
  }

  void _addTextComponent() {
    final textComponent = TextComponent(
      text: text,
      textRenderer: TextPaint(
        style: GoogleFonts.pressStart2p(
          fontSize: 16,
          color: GameColors.primary,
        ),
      ),
    );

    // Center the text
    textComponent.position = size / 2 - textComponent.size / 2;
    add(textComponent);
  }
}