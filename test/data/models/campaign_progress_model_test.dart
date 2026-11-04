import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/data/models/campaign_progress_model.dart';

void main() {
  group('CampaignProgressModel', () {
    test(
      'round trips completed stages, selected hero, and reward balances',
      () {
        final progress = CampaignProgressModel(
          completedStageIds: const {'stage_1', 'stage_2'},
          selectedHeroId: 'hero_blue',
          rewardBalances: const {'gold': 100, 'sp': 25},
        );

        final restored = CampaignProgressModel.fromJson(progress.toJson());

        expect(restored.completedStageIds, {'stage_1', 'stage_2'});
        expect(restored.selectedHeroId, 'hero_blue');
        expect(restored.goldBalance, 100);
        expect(restored.statusPointBalance, 25);
      },
    );

    test('rejects unsupported storage schema versions', () {
      expect(
        () => CampaignProgressModel.fromJson(const {
          'schemaVersion': CampaignProgressModel.schemaVersion + 1,
          'completedStageIds': <String>[],
          'selectedHeroId': null,
          'rewardBalances': <String, int>{},
        }),
        throwsFormatException,
      );
    });

    test('rejects negative local reward balances', () {
      expect(
        () => CampaignProgressModel(rewardBalances: const {'gold': -1}),
        throwsArgumentError,
      );
    });
  });
}
