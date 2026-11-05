import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/data/data_sources/local/campaign_progress_local_data_source.dart';
import 'package:gunwave/data/data_sources/remote/user_remote_data_source.dart';
import 'package:gunwave/l10n/app_localizations.dart';
import 'package:gunwave/repositories/campaign_progress_repository.dart';
import 'package:gunwave/repositories/user_repository.dart';
import 'package:gunwave/theme/theme_provider.dart';
import 'package:gunwave/views/home/home_view.dart';
import 'package:gunwave/views/rpg_ui/rpg_menu_host.dart';
import 'package:gunwave/localization/app_locale_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Play Solo opens the RPG menu without creating a guest account', (
    tester,
  ) async {
    final userRepository = UserRepository(_NoopUserRemoteDataSource());
    final preferences = _MemoryPreferences();
    final progressRepository = CampaignProgressRepository(
      CampaignProgressLocalDataSource(preferences: preferences),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userRepoProvider.overrideWithValue(userRepository),
          campaignProgressRepositoryProvider.overrideWithValue(
            progressRepository,
          ),
          themeProvider.overrideWith((ref) => ThemeProvider.instance),
          appLocaleControllerProvider.overrideWith(
            (ref) => AppLocaleController(preferences: preferences),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: HomeView(),
        ),
      ),
    );

    expect(find.text('Play Solo'), findsOneWidget);
    await tester.tap(find.text('Play Solo'));
    await tester.pump();

    expect(find.byType(RpgMenuHost), findsOneWidget);
    expect(userRepository.appUser, isNull);
  });
}

class _NoopUserRemoteDataSource implements UserRemoteDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MemoryPreferences implements SharedPreferencesAsync {
  final Map<String, Object> values = {};

  @override
  Future<String?> getString(String key) async => values[key] as String?;

  @override
  Future<void> setString(String key, String value) async {
    values[key] = value;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
