import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/views/game/ui/responsive_ui_layout.dart';

void main() {
  test('classifies compact, baseline, and wide landscape viewports', () {
    final compact = ResponsiveUiLayout(viewportSize: Vector2(640, 360));
    final baseline = ResponsiveUiLayout(viewportSize: Vector2(1280, 720));
    final wide = ResponsiveUiLayout(viewportSize: Vector2(1920, 1080));

    expect(compact.viewportClass, GameUiViewportClass.compact);
    expect(compact.scale, ResponsiveUiLayout.compactScale);
    expect(baseline.viewportClass, GameUiViewportClass.baseline);
    expect(baseline.scale, ResponsiveUiLayout.baselineScale);
    expect(wide.viewportClass, GameUiViewportClass.wide);
    expect(wide.scale, ResponsiveUiLayout.wideScale);
  });

  test('safe area bounds remove the supplied device insets', () {
    final layout = ResponsiveUiLayout(
      viewportSize: Vector2(1280, 720),
      safeAreaInsets: const EdgeInsets.fromLTRB(24, 10, 32, 20),
    );

    expect(layout.contentBounds, const Rect.fromLTRB(24, 10, 1248, 700));
  });
}
