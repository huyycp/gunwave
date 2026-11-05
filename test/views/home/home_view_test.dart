import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/data/data_sources/local/campaign_content_data_source.dart';
import 'package:gunwave/data/data_sources/local/local_game_data_seeder.dart';
import 'package:gunwave/data/database/app_database.dart';
import 'package:gunwave/l10n/app_localizations.dart';
import 'package:gunwave/localization/app_locale_controller.dart';
import 'package:gunwave/theme/theme_provider.dart';
import 'package:gunwave/views/home/home_view.dart';
import 'package:gunwave/views/rpg_ui/rpg_menu_host.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Home opens the local RPG hub without account controls', (
    tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    await LocalGameDataSeeder(
      database,
      contentDataSource: AssetCampaignContentDataSource(),
    ).seed();
    addTearDown(database.close);
    final localeController = AppLocaleController(database);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          appLocaleControllerProvider.overrideWith((ref) => localeController),
          themeProvider.overrideWith((ref) => ThemeProvider.forTesting()),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: HomeView(),
        ),
      ),
    );

    expect(find.byType(RpgMenuHost), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Guest'), findsNothing);
    expect(find.text('Play Solo'), findsNothing);
    expect(find.text('Login'), findsNothing);
  });
}
