import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/localization/app_locale_controller.dart';
import 'package:gunwave/localization/app_locale_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('persists each language and restores the selected mode', () async {
    final preferences = MemoryPreferences();
    final controller = AppLocaleController(preferences: preferences);
    addTearDown(controller.dispose);
    for (final mode in AppLocaleMode.values) {
      await controller.setMode(mode);
      final restored = AppLocaleController(preferences: preferences);
      await restored.load();
      expect(restored.mode, mode);
      expect(restored.locale, switch (mode) {
        AppLocaleMode.system => null,
        AppLocaleMode.english => const Locale('en'),
        AppLocaleMode.vietnamese => const Locale('vi'),
      });
      restored.dispose();
    }
  });

  test(
    'rapid changes persist in selection order despite delayed writes',
    () async {
      final preferences = MemoryPreferences()..delay = Completer<void>();
      final controller = AppLocaleController(preferences: preferences);
      addTearDown(controller.dispose);
      final first = controller.setMode(AppLocaleMode.vietnamese);
      final last = controller.setMode(AppLocaleMode.english);
      expect(controller.locale, const Locale('en'));
      preferences.delay!.complete();
      await Future.wait([first, last]);
      expect(preferences.saved, 'english');
    },
  );

  test('unknown preference follows device language', () async {
    final controller = AppLocaleController(
      preferences: MemoryPreferences()..saved = 'unsupported',
    );
    addTearDown(controller.dispose);
    await controller.load();
    expect(controller.mode, AppLocaleMode.system);
    expect(controller.locale, isNull);
  });

  testWidgets('unsupported device locale falls back to English', (
    tester,
  ) async {
    tester.binding.platformDispatcher.localeTestValue = const Locale('fr');
    addTearDown(tester.binding.platformDispatcher.clearLocaleTestValue);
    await tester.pumpWidget(
      MaterialApp(
        supportedLocales: const [Locale('en'), Locale('vi')],
        home: Builder(
          builder: (context) =>
              Text(Localizations.localeOf(context).languageCode),
        ),
      ),
    );
    expect(find.text('en'), findsOneWidget);
  });
}

class MemoryPreferences implements SharedPreferencesAsync {
  String? saved;
  Completer<void>? delay;
  @override
  Future<String?> getString(String key) async => saved;
  @override
  Future<void> setString(String key, String value) async {
    final pending = delay;
    delay = null;
    await pending?.future;
    saved = value;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
