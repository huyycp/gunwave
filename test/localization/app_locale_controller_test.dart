import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/data/database/app_database.dart';
import 'package:gunwave/data/data_sources/local/legacy_preferences_migrator.dart';
import 'package:gunwave/localization/app_locale_controller.dart';
import 'package:gunwave/localization/app_locale_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    await database.customSelect('SELECT 1').get();
  });

  tearDown(() => database.close());

  test('persists every language mode through Drift', () async {
    final controller = AppLocaleController(database);
    addTearDown(controller.dispose);
    for (final mode in AppLocaleMode.values) {
      await controller.setMode(mode);
      final restored = AppLocaleController(database);
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

  test('rapid changes persist in selection order', () async {
    final controller = AppLocaleController(database);
    addTearDown(controller.dispose);
    final first = controller.setMode(AppLocaleMode.vietnamese);
    final last = controller.setMode(AppLocaleMode.english);
    expect(controller.locale, const Locale('en'));
    await Future.wait([first, last]);

    final restored = AppLocaleController(database);
    await restored.load();
    expect(restored.mode, AppLocaleMode.english);
    restored.dispose();
  });

  test('unknown saved mode follows device language', () async {
    await database
        .into(database.settings)
        .insert(
          SettingsCompanion.insert(key: 'locale_mode', value: 'unsupported'),
        );
    final controller = AppLocaleController(database);
    addTearDown(controller.dispose);
    await controller.load();
    expect(controller.mode, AppLocaleMode.system);
    expect(controller.locale, isNull);
  });

  test(
    'imports legacy locale once and discards legacy campaign progress',
    () async {
      final preferences = MemoryPreferences()
        ..values['app_locale_mode'] = 'vietnamese'
        ..values['campaign_progress_v1'] = '{"completedStageIds":["stage_1"]}';
      final migrator = LegacyPreferencesMigrator(
        database,
        preferences: preferences,
      );

      await migrator.migrate();
      preferences.values['app_locale_mode'] = 'english';
      await migrator.migrate();

      final controller = AppLocaleController(database);
      await controller.load();
      expect(controller.mode, AppLocaleMode.vietnamese);
      expect(
        await database.select(database.campaignStageClears).get(),
        isEmpty,
      );
      expect(preferences.values, {'app_locale_mode': 'english'});
      controller.dispose();
    },
  );

  test('invalid legacy locale does not block the one-time migration', () async {
    final preferences = MemoryPreferences()
      ..values['app_locale_mode'] = 'not-a-mode';
    await LegacyPreferencesMigrator(
      database,
      preferences: preferences,
    ).migrate();

    final controller = AppLocaleController(database);
    await controller.load();
    expect(controller.mode, AppLocaleMode.system);
    expect(
      await (database.select(database.appMetadata)
            ..where((row) => row.key.equals('legacy_preferences_migrated_v1')))
          .getSingleOrNull(),
      isNotNull,
    );
    controller.dispose();
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
  final Map<String, Object> values = {};

  @override
  Future<String?> getString(String key) async => values[key] as String?;

  @override
  Future<bool> remove(String key) async => values.remove(key) != null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
