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
    expect(compact.scale, closeTo(ResponsiveUiLayout.compactScale, 0.001));
    expect(baseline.viewportClass, GameUiViewportClass.baseline);
    expect(baseline.scale, closeTo(ResponsiveUiLayout.baselineScale, 0.001));
    expect(wide.viewportClass, GameUiViewportClass.wide);
    expect(wide.scale, closeTo(ResponsiveUiLayout.wideScale, 0.001));
  });

  test(
    'scales continuously between reference viewports and fits narrow space',
    () {
      final compact = ResponsiveUiLayout(viewportSize: Vector2(640, 360));
      final intermediate = ResponsiveUiLayout(viewportSize: Vector2(900, 506));
      final baseline = ResponsiveUiLayout(viewportSize: Vector2(1280, 720));
      final narrow = ResponsiveUiLayout(viewportSize: Vector2(800, 720));

      expect(intermediate.scale, greaterThan(compact.scale));
      expect(intermediate.scale, lessThan(baseline.scale));
      expect(narrow.scale, lessThan(baseline.scale));
      expect(
        narrow.scale,
        greaterThanOrEqualTo(ResponsiveUiLayout.minimumScale),
      );
    },
  );

  test('safe area bounds remove the supplied device insets', () {
    final layout = ResponsiveUiLayout(
      viewportSize: Vector2(1280, 720),
      safeAreaInsets: const EdgeInsets.fromLTRB(24, 10, 32, 20),
    );

    expect(layout.contentBounds, const Rect.fromLTRB(24, 10, 1248, 700));
  });

  test('safe-area insets reduce the responsive scale', () {
    final fullViewport = ResponsiveUiLayout(viewportSize: Vector2(1280, 720));
    final safeViewport = ResponsiveUiLayout(
      viewportSize: Vector2(1280, 720),
      safeAreaInsets: const EdgeInsets.fromLTRB(24, 90, 32, 90),
    );

    expect(safeViewport.scale, lessThan(fullViewport.scale));
  });
}
