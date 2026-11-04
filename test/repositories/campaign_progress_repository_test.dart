import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/data/data_sources/local/campaign_progress_local_data_source.dart';
import 'package:gunwave/data/models/campaign_stage_model.dart';
import 'package:gunwave/data/models/reward_model.dart';
import 'package:gunwave/repositories/campaign_progress_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('CampaignProgressRepository', () {
    late _MemoryPreferences preferences;
    late CampaignProgressRepository repository;

    setUp(() {
      preferences = _MemoryPreferences();
      repository = CampaignProgressRepository(
        CampaignProgressLocalDataSource(preferences: preferences),
      );
    });

    test('awards all configured rewards on first completion', () async {
      final completion = await repository.completeStage(_stage());

      expect(completion.wasFirstCompletion, isTrue);
      expect(completion.progress.completedStageIds, {'stage_1'});
      expect(completion.progress.goldBalance, 100);
      expect(completion.progress.statusPointBalance, 25);
    });

    test('replay and repeated completion do not grant rewards again', () async {
      await repository.completeStage(_stage());

      final replay = await repository.completeStage(_stage());
      final restored = await repository.getProgress();

      expect(replay.wasFirstCompletion, isFalse);
      expect(replay.progress.goldBalance, 100);
      expect(restored.statusPointBalance, 25);
    });

    test(
      'concurrent completion attempts serialize the first reward claim',
      () async {
        final completions = await Future.wait([
          repository.completeStage(_stage()),
          repository.completeStage(_stage()),
        ]);
        final restored = await repository.getProgress();

        expect(
          completions.where((result) => result.wasFirstCompletion),
          hasLength(1),
        );
        expect(restored.goldBalance, 100);
        expect(restored.completedStageIds, {'stage_1'});
      },
    );

    test('selected hero survives repository recreation', () async {
      await repository.selectHero('hero_red');
      repository = CampaignProgressRepository(
        CampaignProgressLocalDataSource(preferences: preferences),
      );

      final progress = await repository.getProgress();

      expect(progress.selectedHeroId, 'hero_red');
    });

    test('rejects unknown or negative rewards', () {
      expect(
        () => repository.completeStage(
          _stage(
            rewards: const [RewardModel(type: RewardType.unknown, amount: 4)],
          ),
        ),
        throwsArgumentError,
      );
      expect(
        () => repository.completeStage(
          _stage(
            rewards: const [RewardModel(type: RewardType.gold, amount: -1)],
          ),
        ),
        throwsArgumentError,
      );
    });
  });
}

CampaignStageModel _stage({List<RewardModel>? rewards}) => CampaignStageModel(
  id: 'stage_1',
  rewards:
      rewards ??
      const [
        RewardModel(type: RewardType.gold, amount: 100),
        RewardModel(type: RewardType.sp, amount: 25),
      ],
);

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
