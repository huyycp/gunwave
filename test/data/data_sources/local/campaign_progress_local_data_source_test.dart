import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/data/data_sources/local/campaign_progress_local_data_source.dart';
import 'package:gunwave/data/models/campaign_progress_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('CampaignProgressLocalDataSource', () {
    late _MemoryPreferences preferences;
    late CampaignProgressLocalDataSource dataSource;

    setUp(() {
      preferences = _MemoryPreferences();
      dataSource = CampaignProgressLocalDataSource(preferences: preferences);
    });

    test('returns empty progress when nothing has been saved', () async {
      final progress = await dataSource.load();

      expect(progress.completedStageIds, isEmpty);
      expect(progress.selectedHeroId, isNull);
      expect(progress.rewardBalances, isEmpty);
    });

    test(
      'restores progress from its single serialized preference value',
      () async {
        final progress = CampaignProgressModel(
          completedStageIds: const {'stage_1'},
          selectedHeroId: 'hero_blue',
          rewardBalances: const {'gold': 100, 'sp': 25},
        );

        await dataSource.save(progress);
        final restored = await dataSource.load();

        expect(preferences.values, hasLength(1));
        expect(restored.completedStageIds, {'stage_1'});
        expect(restored.selectedHeroId, 'hero_blue');
        expect(restored.goldBalance, 100);
        expect(restored.statusPointBalance, 25);
      },
    );

    test(
      'surfaces malformed persisted JSON instead of erasing progress',
      () async {
        preferences.values[CampaignProgressLocalDataSource.storageKey] = '{';

        expect(dataSource.load(), throwsFormatException);
      },
    );
  });
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
