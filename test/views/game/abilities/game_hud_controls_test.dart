import 'dart:ui';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/data/constants/game/game_hud_style.dart';
import 'package:gunwave/data/constants/game/game_hub.dart';
import 'package:gunwave/views/game/game_touch_control_layout.dart';
import 'package:gunwave/views/game/components/sub_components/attack_button.dart';
import 'package:gunwave/views/game/components/sub_components/pixel_joystick_disc.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('joystick, attack, and ability positions include safe-area insets', () {
    const safeArea = EdgeInsets.fromLTRB(10, 12, 20, 30);

    expect(
      GameTouchControlLayout.joystickMargin(safeArea),
      const EdgeInsets.only(left: 34, bottom: 54),
    );
    expect(
      GameTouchControlLayout.attackPosition(Vector2(390, 844), safeArea),
      Vector2(282, 726),
    );
    expect(
      GameTouchControlLayout.abilityInsets(safeArea),
      const EdgeInsets.only(right: 44, bottom: 130),
    );
  });

  test(
    'pixel joystick discs keep their 128 and 64 pixel touch sizes',
    () async {
      final game = FlameGame();
      game.onGameResize(Vector2(320, 240));
      // Exercise Flame lifecycle directly without loading a production map.
      // ignore: invalid_use_of_internal_member
      await game.load();
      // ignore: invalid_use_of_internal_member
      game.mount();
      final background = PixelJoystickDisc.background();
      final knob = PixelJoystickDisc.knob();
      game.world.add(background);
      game.world.add(knob);
      await game.ready();

      expect(background.size, Vector2.all(GameHudStyle.joystickDiameter));
      expect(knob.size, Vector2.all(GameHudStyle.joystickKnobDiameter));
      for (final disc in [background, knob]) {
        final recorder = PictureRecorder();
        disc.render(Canvas(recorder));
        final picture = recorder.endRecording();
        final image = await picture.toImage(
          disc.size.x.toInt(),
          disc.size.y.toInt(),
        );
        final bytes = (await image.toByteData())!.buffer.asUint8List();
        expect(bytes.any((value) => value != 0), isTrue);
        image.dispose();
        picture.dispose();
      }
      game.onRemove();
    },
  );

  test('attack button swaps pixel frames for press and release', () async {
    final game = FlameGame();
    game.onGameResize(Vector2(320, 240));
    game.images.prefix = '';
    await game.images.load(GameHubs.attackButton.path);
    await game.images.load(GameHubs.attackButtonPressed.path);
    // Exercise Flame lifecycle directly without loading a production map.
    // ignore: invalid_use_of_internal_member
    await game.load();
    // ignore: invalid_use_of_internal_member
    game.mount();
    final attacks = <bool>[];
    final button = AttachButton(
      onAttack: attacks.add,
      size: Vector2.all(GameHudStyle.touchAttackSize),
    );
    game.world.add(button);
    await game.ready();

    expect(button.size, Vector2.all(64));
    button.onTapDown(
      TapDownEvent(
        1,
        game,
        TapDownDetails(
          kind: PointerDeviceKind.touch,
          globalPosition: Offset.zero,
        ),
      ),
    );
    expect(button.isPressed, isTrue);
    expect(
      button.sprite!.image,
      same(game.images.fromCache(GameHubs.attackButtonPressed.path)),
    );

    button.onTapUp(
      TapUpEvent(
        1,
        game,
        TapUpDetails(
          kind: PointerDeviceKind.touch,
          globalPosition: Offset.zero,
        ),
      ),
    );
    expect(button.isPressed, isFalse);
    expect(
      button.sprite!.image,
      same(game.images.fromCache(GameHubs.attackButton.path)),
    );
    expect(attacks, [true, false]);
    game.onRemove();
  });
}
