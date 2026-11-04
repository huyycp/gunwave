import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/l10n/app_localizations.dart';
import 'package:gunwave/views/rpg_ui/rpg_menu_game.dart';
import 'package:gunwave/views/rpg_ui/rpg_menu_host.dart';
import 'package:gunwave/views/rpg_ui/rpg_menu_models.dart';
import 'package:gunwave/localization/app_locale_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Campaign menu host renders its screen through Flame', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(
      overrides: [
        appLocaleControllerProvider.overrideWith(
          (ref) => AppLocaleController(preferences: _MemoryPreferences()),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: RpgMenuHost(initialPage: RpgMenuPage.campaignMap),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(GameWidget<RpgMenuGame>), findsOneWidget);
    expect(find.byType(Text), findsNothing);
  });
}

class _MemoryPreferences implements SharedPreferencesAsync {
  @override
  Future<String?> getString(String key) async => null;

  @override
  Future<void> setString(String key, String value) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
