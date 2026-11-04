import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flame/cache.dart';
import 'package:flame/text.dart';
import 'package:flutter/services.dart';
import 'package:gunwave/data/constants/game/game_ui.dart';

/// Loads the bundled pixel font atlas and exposes Flame's sprite renderer.
abstract final class UiBitmapFont {
  static Future<UiBitmapFontRenderer> load(
    Images images, {
    AssetBundle? bundle,
    ui.Color? color,
    double scale = 1,
    double letterSpacing = 0,
  }) async {
    final fontImagePath = GameUiAssets.font.path;
    final imageKey = fontImagePath.startsWith(images.prefix)
        ? fontImagePath.substring(images.prefix.length)
        : fontImagePath;
    final image = await images.load(imageKey);
    final metadata = jsonDecode(
      await (bundle ?? rootBundle).loadString(GameUiAssets.fontMetadataPath),
    ) as Map<String, dynamic>;
    return fromMetadata(
      image,
      metadata,
      color: color,
      scale: scale,
      letterSpacing: letterSpacing,
    );
  }

  /// Creates a renderer from generated atlas metadata, also useful for tests.
  static UiBitmapFontRenderer fromMetadata(
    ui.Image image,
    Map<String, dynamic> metadata, {
    ui.Color? color,
    double scale = 1,
    double letterSpacing = 0,
  }) {
    final glyphRecords = metadata['glyphs'] as List<dynamic>;
    final glyphs = <Glyph>[];
    final supportedCharacters = <String>{};
    final width = (metadata['cellWidth'] as num).toDouble();
    final height = (metadata['cellHeight'] as num).toDouble();
    for (final record in glyphRecords) {
      final glyph = record as Map<String, dynamic>;
      final char = glyph['char'] as String;
      supportedCharacters.add(char);
      glyphs.add(
        Glyph(
          char,
          left: (glyph['x'] as num).toDouble(),
          top: (glyph['y'] as num).toDouble(),
          width: width,
          height: height,
        ),
      );
    }

    final fallback = metadata['fallback'] as String;
    if (!supportedCharacters.contains(fallback)) {
      throw const FormatException('The bitmap font fallback glyph is missing.');
    }

    final font = SpriteFont(
      source: image,
      size: (metadata['size'] as num).toDouble(),
      ascent: (metadata['ascent'] as num).toDouble(),
      glyphs: glyphs,
      defaultCharWidth: width,
    );
    return UiBitmapFontRenderer(
      font,
      supportedCharacters: supportedCharacters,
      fallback: fallback,
      color: color,
      scale: scale,
      letterSpacing: letterSpacing,
    );
  }
}

/// Substitutes unsupported Unicode characters with the visible fallback glyph.
class UiBitmapFontRenderer extends SpriteFontRenderer {
  UiBitmapFontRenderer(
    SpriteFont font, {
    required Set<String> supportedCharacters,
    required this.fallback,
    ui.Color? color,
    double scale = 1,
    double letterSpacing = 0,
  }) : _supportedCharacters = Set.unmodifiable(supportedCharacters),
       super.fromFont(
         font,
         color: color,
         scale: scale,
         letterSpacing: letterSpacing,
       );

  final Set<String> _supportedCharacters;
  final String fallback;

  String sanitize(String text) => String.fromCharCodes(
    text.runes.map((rune) {
      final character = String.fromCharCode(rune);
      return _supportedCharacters.contains(character)
          ? rune
          : fallback.runes.single;
    }),
  );

  @override
  SpriteFontTextElement format(String text) => super.format(sanitize(text));
}
