import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/text.dart';
import 'package:gunwave/data/constants/game/game_button.dart';
import 'package:gunwave/data/constants/game/game_hud_style.dart';
import 'package:gunwave/theme/app_typography.dart';

import 'asset_panel_component.dart';

/// A nine-slice button with an independent minimum touch target.
class AssetButtonComponent extends PositionComponent
    with TapCallbacks, HoverCallbacks, HasVisibility {
  AssetButtonComponent({
    required Sprite normalSprite,
    Sprite? hoveredSprite,
    required Sprite pressedSprite,
    Sprite? disabledSprite,
    required Vector2 size,
    Vector2? hitAreaSize,
    bool enabled = true,
    String label = '',
    this.labelRenderer,
    this.labelFontSize = AppTypography.bodySmallSize,
    this.onPressed,
    NineSliceBorders borders = const NineSliceBorders(
      left: GameHudStyle.buttonBorderInset,
      top: GameHudStyle.buttonBorderInset,
      right: GameHudStyle.buttonBorderInset,
      bottom: GameHudStyle.buttonBorderInset,
    ),
    super.position,
    super.anchor,
    super.priority,
    super.key,
  }) : _normal = _nineSlice(normalSprite, borders),
       _hovered = _nineSlice(hoveredSprite ?? normalSprite, borders),
       _pressed = _nineSlice(pressedSprite, borders),
       _disabled = disabledSprite == null
           ? null
           : _nineSlice(disabledSprite, borders),
       _hitAreaSize = _minimumHitArea(hitAreaSize ?? Vector2.zero()),
       _buttonState = enabled
           ? GameButtonState.enabled
           : GameButtonState.disabled,
       super(size: size) {
    _setLabel(label);
  }

  final NineTileBox _normal;
  final NineTileBox _hovered;
  final NineTileBox _pressed;
  final NineTileBox? _disabled;
  final Vector2 _hitAreaSize;
  final SpriteFontRenderer? labelRenderer;
  final double labelFontSize;
  final void Function()? onPressed;

  GameButtonState _buttonState;
  bool _isPressed = false;
  bool _isHovered = false;
  TextComponent<SpriteFontRenderer>? _label;

  bool get enabled => _buttonState != GameButtonState.disabled;

  set enabled(bool value) {
    _buttonState = value ? GameButtonState.enabled : GameButtonState.disabled;
    if (!value) {
      _isPressed = false;
      _isHovered = false;
    }
  }

  String get label => _label?.text ?? '';

  set label(String value) => _setLabel(value);

  /// Returns the drawn sprite state; the caller may resize [size] freely.
  GameButtonState get visualState {
    if (_buttonState == GameButtonState.disabled) {
      return GameButtonState.disabled;
    }
    if (_isPressed) return GameButtonState.pressed;
    return _isHovered ? GameButtonState.hovered : GameButtonState.enabled;
  }

  @override
  set size(Vector2 value) {
    super.size = value;
    final label = _label;
    if (label != null) {
      label.position.setValues(
        width / 2,
        height / 2 + GameHudStyle.buttonLabelOpticalYOffset,
      );
    }
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    final hitWidth = math.max(width, _hitAreaSize.x);
    final hitHeight = math.max(height, _hitAreaSize.y);
    return Rect.fromLTWH(
      (width - hitWidth) / 2,
      (height - hitHeight) / 2,
      hitWidth,
      hitHeight,
    ).contains(Offset(point.x, point.y));
  }

  @override
  void render(Canvas canvas) {
    final nineTileBox = switch (visualState) {
      GameButtonState.enabled => _normal,
      GameButtonState.hovered => _hovered,
      GameButtonState.pressed => _pressed,
      GameButtonState.disabled => _disabled ?? _normal,
    };
    nineTileBox.drawRect(canvas, size.toRect());
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (enabled) _isPressed = true;
  }

  @override
  void onTapUp(TapUpEvent event) {
    final shouldActivate = enabled && _isPressed;
    _isPressed = false;
    if (shouldActivate) onPressed?.call();
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _isPressed = false;
  }

  @override
  void onHoverEnter() {
    if (enabled) _isHovered = true;
  }

  @override
  void onHoverExit() {
    _isHovered = false;
  }

  void _setLabel(String value) {
    final currentLabel = _label;
    if (currentLabel != null) {
      currentLabel.text = value;
      return;
    }
    if (value.isEmpty) return;
    final renderer = labelRenderer;
    if (renderer == null) {
      throw StateError(
        'A sprite font renderer is required for a button label.',
      );
    }
    _label = TextComponent<SpriteFontRenderer>(
      text: value,
      textRenderer: renderer,
      anchor: Anchor.center,
      position: Vector2(
        width / 2,
        height / 2 + GameHudStyle.buttonLabelOpticalYOffset,
      ),
      scale: Vector2.all(AppTypography.bitmapScale(labelFontSize)),
    );
    add(_label!);
  }

  static NineTileBox _nineSlice(Sprite sprite, NineSliceBorders borders) =>
      NineTileBox.withGrid(
        sprite,
        leftWidth: borders.left,
        topHeight: borders.top,
        rightWidth: borders.right,
        bottomHeight: borders.bottom,
      );

  static Vector2 _minimumHitArea(Vector2 requested) => Vector2(
    math.max(GameHudStyle.minimumTouchSize, requested.x),
    math.max(GameHudStyle.minimumTouchSize, requested.y),
  );

  /// Loads the selected state sprites from the project's generated asset catalog.
  static Future<AssetButtonComponent> load(
    Images images, {
    required GameButtonSize buttonSize,
    required Vector2 size,
    Vector2? position,
    Anchor? anchor,
    Vector2? hitAreaSize,
    bool enabled = true,
    String label = '',
    SpriteFontRenderer? labelRenderer,
    double labelFontSize = AppTypography.bodySmallSize,
    void Function()? onPressed,
  }) async {
    final assets = GameButtonAssets.forSize(buttonSize);
    final paths = [
      assets.normal.path,
      assets.hovered.path,
      assets.pressed.path,
      assets.disabled.path,
    ];
    final sprites = await Future.wait(
      paths.map((path) async {
        final key = path.startsWith(images.prefix)
            ? path.substring(images.prefix.length)
            : path;
        return Sprite(await images.load(key));
      }),
    );
    return AssetButtonComponent(
      normalSprite: sprites[0],
      hoveredSprite: sprites[1],
      pressedSprite: sprites[2],
      disabledSprite: sprites[3],
      size: size,
      position: position,
      anchor: anchor,
      hitAreaSize: hitAreaSize,
      enabled: enabled,
      label: label,
      labelRenderer: labelRenderer,
      labelFontSize: labelFontSize,
      onPressed: onPressed,
    );
  }
}
