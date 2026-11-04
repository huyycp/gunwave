import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:gunwave/data/constants/game/game_hud_style.dart';

import 'asset_panel_component.dart';

/// A resizable progress bar made from three nine-slice sprites.
class AssetProgressBarComponent extends PositionComponent {
  AssetProgressBarComponent({
    required Sprite frameSprite,
    required Sprite backgroundSprite,
    required Sprite fillSprite,
    required Vector2 size,
    double value = 1,
    this.inset = GameHudStyle.progressBarInset,
    NineSliceBorders borders = const NineSliceBorders(
      left: GameHudStyle.progressBarBorderInset,
      top: GameHudStyle.progressBarBorderInset,
      right: GameHudStyle.progressBarBorderInset,
      bottom: GameHudStyle.progressBarBorderInset,
    ),
    super.position,
    super.anchor,
    super.priority,
  }) : _frame = _nineSlice(frameSprite, borders),
       _background = _nineSlice(backgroundSprite, borders),
       _fill = _nineSlice(fillSprite, borders),
       _value = normalizedValue(value),
       super(size: size);

  final NineTileBox _frame;
  final NineTileBox _background;
  final NineTileBox _fill;
  final double inset;

  double _value;

  double get value => _value;

  set value(double value) => _value = normalizedValue(value);

  static double normalizedValue(double value) {
    if (!value.isFinite) return 0;
    return value.clamp(0.0, 1.0).toDouble();
  }

  @override
  void render(Canvas canvas) {
    final outer = size.toRect();
    final inner = Rect.fromLTRB(
      inset,
      inset,
      math.max(inset, width - inset),
      math.max(inset, height - inset),
    );
    _background.drawRect(canvas, inner);
    if (value > 0 && inner.width > 0 && inner.height > 0) {
      canvas.save();
      canvas.clipRect(
        Rect.fromLTWH(inner.left, inner.top, inner.width * value, inner.height),
      );
      _fill.drawRect(canvas, inner);
      canvas.restore();
    }
    _frame.drawRect(canvas, outer);
  }

  static NineTileBox _nineSlice(Sprite sprite, NineSliceBorders borders) =>
      NineTileBox.withGrid(
        sprite,
        leftWidth: borders.left,
        topHeight: borders.top,
        rightWidth: borders.right,
        bottomHeight: borders.bottom,
      );
}
