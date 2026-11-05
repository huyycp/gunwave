import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/data_sources/local/campaign_progress_local_data_source.dart';
import 'package:gunwave/data/models/campaign_progress_model.dart';
import 'package:gunwave/data/models/campaign_stage_model.dart';
import 'package:gunwave/data/models/reward_model.dart';

final campaignProgressRepositoryProvider = Provider<CampaignProgressRepository>(
  (ref) => CampaignProgressRepository(
    ref.read(campaignProgressLocalDataSourceProvider),
  ),
);

/// Owns device-local campaign clears and first-clear rewards.
class CampaignProgressRepository {
  CampaignProgressRepository(this._localDataSource);

  final CampaignProgressLocalDataSource _localDataSource;

  Future<CampaignProgressModel> getProgress() => _localDataSource.load();

  Future<CampaignProgressModel> selectHero(String heroId) {
    if (heroId.trim().isEmpty) {
      throw ArgumentError.value(heroId, 'heroId', 'Hero ID must not be empty.');
    }
    return _localDataSource.selectHero(heroId);
  }

  Future<CampaignStageCompletion> completeStage(CampaignStageModel stage) {
    if (stage.id.trim().isEmpty) {
      throw ArgumentError.value(stage.id, 'stage.id', 'Stage ID is required.');
    }
    _validateRewards(stage.rewards);
    return _localDataSource.completeStage(stage);
  }

  void _validateRewards(List<RewardModel> rewards) {
    for (final reward in rewards) {
      if (reward.type == RewardType.unknown || reward.amount < 0) {
        throw ArgumentError.value(
          reward,
          'stage.rewards',
          'Reward types must be known and amounts cannot be negative.',
        );
      }
    }
  }
}
