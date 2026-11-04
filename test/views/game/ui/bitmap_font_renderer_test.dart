import 'package:flame_test/flame_test.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/views/game/ui/bitmap_font.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWithFlameGame('bitmap font renders localized glyphs and falls back', (
    game,
  ) async {
    final renderer = await UiBitmapFont.load(game.images);
    const localizedLabel = 'Tiếng Việt: ải 1-5 • boss';

    expect(() => renderer.format(localizedLabel), returnsNormally);
    expect(renderer.sanitize(localizedLabel), localizedLabel);
    expect(renderer.sanitize('Map \u2603'), 'Map ?');
    expect(() => renderer.format('Map \u2603'), returnsNormally);

    final textBox = TextBoxComponent<UiBitmapFontRenderer>(
      text: 'Tiếng Việt: bảo vệ thế giới',
      textRenderer: renderer,
      boxConfig: const TextBoxConfig(maxWidth: 64, margins: EdgeInsets.zero),
      size: Vector2(64, 80),
    );
    await game.ensureAdd(textBox);
    expect(textBox.lines.length, greaterThan(1));
  });
}
