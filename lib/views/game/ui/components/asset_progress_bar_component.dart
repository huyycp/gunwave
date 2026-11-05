import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

/// A responsive progress bar that keeps its end caps at their source ratio.
class AssetProgressBarComponent extends PositionComponent with HasVisibility {
  AssetProgressBarComponent({
    required Sprite frameSprite,
    required Sprite fillSprite,
    required double capWidth,
    required Vector2 size,
    double value = 1,
    Color? fillTint,
    super.position,
    super.anchor,
    super.priority,
  }) : _sourceCapWidth = capWidth,
       _frameLeft = _slice(frameSprite, 0, capWidth),
       _frameCenter = _slice(
         frameSprite,
         capWidth,
         frameSprite.srcSize.x - capWidth * 2,
       ),
       _frameRight = _slice(
         frameSprite,
         frameSprite.srcSize.x - capWidth,
         capWidth,
       ),
       _fill = _prepareFill(fillSprite, fillTint),
       _value = normalizedValue(value),
       super(size: size);

  final double _sourceCapWidth;
  final Sprite _frameLeft;
  final Sprite _frameCenter;
  final Sprite _frameRight;
  final Sprite _fill;
  double _value;

  double get value => _value;

  set value(double value) => _value = normalizedValue(value);

  static double normalizedValue(double value) {
    if (!value.isFinite) return 0;
    return value.clamp(0.0, 1.0).toDouble();
  }

  @override
  void render(Canvas canvas) {
    final frameHeight = _frameCenter.srcSize.y;
    if (width <= 0 || height <= 0 || frameHeight <= 0) return;

    final capWidth = math.min(
      _sourceCapWidth * height / frameHeight,
      width / 2,
    );
    final centerWidth = math.max(0.0, width - capWidth * 2);
    _frameLeft.render(canvas, size: Vector2(capWidth, height));
    _frameRight.render(
      canvas,
      position: Vector2(width - capWidth, 0),
      size: Vector2(capWidth, height),
    );
    if (centerWidth > 0) {
      _frameCenter.render(
        canvas,
        position: Vector2(capWidth, 0),
        size: Vector2(centerWidth, height),
      );
    }

    if (_value == 0 || centerWidth == 0) return;
    final fillHeight = math.min(height, height * _fill.srcSize.y / frameHeight);
    final fillWidth = centerWidth * _value;
    final fillTop = (height - fillHeight) / 2;
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(capWidth, 0, fillWidth, height));
    _fill.render(
      canvas,
      position: Vector2(capWidth, fillTop),
      size: Vector2(centerWidth, fillHeight),
    );
    canvas.restore();
  }

  static Sprite _slice(Sprite sprite, double offsetX, double width) {
    final slice = Sprite(
      sprite.image,
      srcPosition: Vector2(sprite.src.left + offsetX, sprite.src.top),
      srcSize: Vector2(width, sprite.src.height),
    );
    slice.paint = Paint()..filterQuality = FilterQuality.none;
    return slice;
  }

  static Sprite _prepareFill(Sprite sprite, Color? tint) {
    sprite.paint = Paint()
      ..filterQuality = FilterQuality.none
      ..colorFilter = tint == null
          ? null
          : ColorFilter.mode(tint, BlendMode.srcIn);
    return sprite;
  }
}
