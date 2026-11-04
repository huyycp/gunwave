import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

enum GameUiViewportClass { compact, baseline, wide }

/// Safe bounds and density scale for screen-space Flame UI.
class ResponsiveUiLayout {
  ResponsiveUiLayout({
    required Vector2 viewportSize,
    EdgeInsets safeAreaInsets = EdgeInsets.zero,
  }) : viewportSize = viewportSize.clone(),
       safeAreaInsets = safeAreaInsets,
       contentBounds = Rect.fromLTRB(
         safeAreaInsets.left,
         safeAreaInsets.top,
         math.max(safeAreaInsets.left, viewportSize.x - safeAreaInsets.right),
         math.max(safeAreaInsets.top, viewportSize.y - safeAreaInsets.bottom),
       ),
       viewportClass = _classify(viewportSize),
       scale = _scaleFor(viewportSize);

  static const compactViewportWidth = 720.0;
  static const compactViewportHeight = 400.0;
  static const wideViewportWidth = 1440.0;
  static const wideAspectRatio = 1.5;
  static const compactScale = 0.85;
  static const baselineScale = 1.0;
  static const wideScale = 1.1;

  final Vector2 viewportSize;
  final EdgeInsets safeAreaInsets;
  final Rect contentBounds;
  final GameUiViewportClass viewportClass;
  final double scale;

  static GameUiViewportClass _classify(Vector2 size) {
    if (size.x < compactViewportWidth || size.y < compactViewportHeight) {
      return GameUiViewportClass.compact;
    }
    if (size.x >= wideViewportWidth && size.x / size.y >= wideAspectRatio) {
      return GameUiViewportClass.wide;
    }
    return GameUiViewportClass.baseline;
  }

  static double _scaleFor(Vector2 size) => switch (_classify(size)) {
    GameUiViewportClass.compact => compactScale,
    GameUiViewportClass.baseline => baselineScale,
    GameUiViewportClass.wide => wideScale,
  };
}
