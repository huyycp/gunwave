import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/data/constants/game/game_button.dart';
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

    expect(button.size.x, 36);
    expect(button.size.y, 30);
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
}
