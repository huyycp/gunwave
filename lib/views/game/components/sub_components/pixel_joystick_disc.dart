import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:gunwave/data/constants/game/game_hud_style.dart';

/// Prepaints a pixel-grid joystick base or knob for the Flame joystick control.
class PixelJoystickDisc extends PositionComponent {
  /// Creates the translucent pixel-grid base for a [JoystickComponent].
  PixelJoystickDisc.background()
    : _isKnob = false,
      super(size: Vector2.all(GameHudStyle.joystickDiameter));

  /// Creates the movable pixel-grid thumb for a [JoystickComponent].
  PixelJoystickDisc.knob()
    : _isKnob = true,
      super(size: Vector2.all(GameHudStyle.joystickKnobDiameter));

  static const cellSize = 8.0;
  static const _knobOutlineStart = .84;
  static const _knobShadeStart = .60;
  static const _knobHighlightSize = .32;
  static const _baseOutlineStart = .86;
  static const _baseOuterShadeStart = .68;
  static const _baseInnerShadeStart = .38;

  final bool _isKnob;
  ui.Picture? _picture;

  /// Builds one cached block drawing; dragging only moves this picture.
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final columns = (size.x / cellSize).ceil();
    final rows = (size.y / cellSize).ceil();
    final center = Offset(size.x / 2, size.y / 2);
    final radius = math.min(size.x, size.y) / 2;
    final paint = Paint()..isAntiAlias = false;

    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns; column++) {
        final cellCenter = Offset(
          (column + .5) * cellSize,
          (row + .5) * cellSize,
        );
        final distance = (cellCenter - center).distance / radius;
        if (distance > 1) continue;
        final color = _colorFor(distance);
        if (color == null) continue;
        paint.color = color;
        canvas.drawRect(
          Rect.fromLTWH(column * cellSize, row * cellSize, cellSize, cellSize),
          paint,
        );
      }
    }
    _picture = recorder.endRecording();
  }

  Color? _colorFor(double distance) {
    if (_isKnob) {
      if (distance > _knobOutlineStart) return const Color(0xFF18222D);
      if (distance > _knobShadeStart) return const Color(0xFF516875);
      if (distance < _knobHighlightSize) return const Color(0xFFC2D1D7);
      return const Color(0xFF91A8B2);
    }
    if (distance > _baseOutlineStart) return const Color(0xCC101923);
    if (distance > _baseOuterShadeStart) return const Color(0xAA3D5968);
    if (distance > _baseInnerShadeStart) return const Color(0x882A414E);
    return const Color(0x55435F6A);
  }

  /// Reuses the cached disc picture for each Flame render frame.
  @override
  void render(Canvas canvas) {
    final picture = _picture;
    if (picture != null) canvas.drawPicture(picture);
    super.render(canvas);
  }

  /// Releases the cached drawing when Flame removes this control component.
  @override
  void onRemove() {
    _picture?.dispose();
    _picture = null;
    super.onRemove();
  }
}
