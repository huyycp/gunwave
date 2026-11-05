import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/text.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/data/constants/game/game_button.dart';
import 'package:gunwave/data/constants/game/game_hud_style.dart';
import 'package:gunwave/theme/app_typography.dart';
import 'package:gunwave/views/game/ui/bitmap_font.dart';
import 'package:gunwave/views/game/ui/components/asset_button_component.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWithFlameGame('button draws at custom size and keeps a 48px hit area', (
    game,
  ) async {
    final font = await UiBitmapFont.load(game.images);
    var activations = 0;
    final button = await AssetButtonComponent.load(
      game.images,
      buttonSize: GameButtonSize.medium,
      size: Vector2(36, 30),
      label: 'PLAY',
      labelRenderer: font,
      onPressed: () => activations++,
    );
    await game.ensureAdd(button);
    final label = button.children
        .whereType<TextComponent<SpriteFontRenderer>>()
        .single;

    expect(button.size.x, 36);
    expect(button.size.y, 30);
    expect(label.position.x, button.width / 2);
    expect(
      label.position.y,
      closeTo(
        button.height / 2 +
            GameHudStyle.buttonLabelOpticalOffsetForHeight(button.height),
        0.001,
      ),
    );
    expect(button.containsLocalPoint(Vector2(-6, 15)), isTrue);
    expect(button.containsLocalPoint(Vector2(42, 15)), isFalse);
    expect(button.visualState, GameButtonState.enabled);
    button.onHoverEnter();
    expect(button.visualState, GameButtonState.hovered);
    button.onHoverExit();

    button.onTapDown(
      TapDownEvent(1, game, TapDownDetails(globalPosition: Offset.zero)),
    );
    expect(button.visualState, GameButtonState.pressed);
    button.onTapUp(
      TapUpEvent(
        1,
        game,
        TapUpDetails(
          globalPosition: Offset.zero,
          kind: PointerDeviceKind.touch,
        ),
      ),
    );
    expect(activations, 1);

    button.size = Vector2(96, 44);
    expect(button.label, 'PLAY');
    expect(label.position.x, button.width / 2);
    expect(
      label.position.y,
      closeTo(
        button.height / 2 +
            GameHudStyle.buttonLabelOpticalOffsetForHeight(button.height),
        0.001,
      ),
    );
    expect(button.containsLocalPoint(Vector2(95, 22)), isTrue);

    button.enabled = false;
    expect(button.visualState, GameButtonState.disabled);
    button.onTapDown(
      TapDownEvent(2, game, TapDownDetails(globalPosition: Offset.zero)),
    );
    button.onTapUp(
      TapUpEvent(
        2,
        game,
        TapUpDetails(
          globalPosition: Offset.zero,
          kind: PointerDeviceKind.touch,
        ),
      ),
    );
    expect(activations, 1);
  });

  testWithFlameGame('button label role follows its visible button height', (
    game,
  ) async {
    final font = await UiBitmapFont.load(game.images);
    final compact = await AssetButtonComponent.load(
      game.images,
      buttonSize: GameButtonSize.small,
      size: Vector2(72, 48),
      label: 'OK',
      labelRenderer: font,
    );
    final standard = await AssetButtonComponent.load(
      game.images,
      buttonSize: GameButtonSize.medium,
      size: Vector2(180, 56),
      label: 'Settings',
      labelRenderer: font,
    );
    final prominent = await AssetButtonComponent.load(
      game.images,
      buttonSize: GameButtonSize.large,
      size: Vector2(220, 68),
      label: 'Continue',
      labelRenderer: font,
    );
    await game.ensureAdd(compact);
    await game.ensureAdd(standard);
    await game.ensureAdd(prominent);

    expect(compact.labelFontSize, 16);
    expect(standard.labelFontSize, 22);
    expect(prominent.labelFontSize, 24);

    final prominentLabel = prominent.children
        .whereType<TextComponent<SpriteFontRenderer>>()
        .single;
    expect(
      prominentLabel.width * prominentLabel.scale.x,
      lessThanOrEqualTo(
        prominent.width - GameHudStyle.buttonLabelHorizontalInset * 2,
      ),
    );

    standard.size = Vector2(180, 64);
    expect(standard.labelFontSize, 22);
    standard.responsiveTextScale = 0.85;
    final standardLabel = standard.children
        .whereType<TextComponent<SpriteFontRenderer>>()
        .single;
    expect(
      standardLabel.scale.x,
      closeTo(AppTypography.titleLargeSize * 0.85 / 14, 0.001),
    );
  });
}
