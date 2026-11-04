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

/// Owns serialized local campaign progress and first-completion rewards.
class CampaignProgressRepository {
  CampaignProgressRepository(this._localDataSource);

  final CampaignProgressLocalDataSource _localDataSource;
  Future<void> _pendingOperation = Future<void>.value();

  /// Loads the latest committed progress after any queued mutations finish.
  Future<CampaignProgressModel> getProgress() =>
      _serialize(_localDataSource.load);

  /// Saves the selected hero ID in the same record as clears and rewards.
  Future<CampaignProgressModel> selectHero(String heroId) {
    if (heroId.trim().isEmpty) {
      throw ArgumentError.value(heroId, 'heroId', 'Hero ID must not be empty.');
    }
    return _serialize(() async {
      final progress = await _localDataSource.load();
      final updated = progress.copyWith(selectedHeroId: heroId);
      await _localDataSource.save(updated);
      return updated;
    });
  }

  /// Clears [stage] and applies its rewards once, in the same stored record.
  Future<CampaignStageCompletion> completeStage(CampaignStageModel stage) {
    if (stage.id.trim().isEmpty) {
      throw ArgumentError.value(stage.id, 'stage.id', 'Stage ID is required.');
    }
    _validateRewards(stage.rewards);

    return _serialize(() async {
      final progress = await _localDataSource.load();
      if (progress.completedStageIds.contains(stage.id)) {
        return CampaignStageCompletion(
          progress: progress,
          wasFirstCompletion: false,
        );
      }

      final balances = Map<String, int>.of(progress.rewardBalances);
      for (final reward in stage.rewards) {
        if (reward.amount == 0) continue;
        final key = reward.type.name;
        balances.update(
          key,
          (balance) => balance + reward.amount,
          ifAbsent: () => reward.amount,
        );
      }
      final updated = progress.copyWith(
        completedStageIds: {...progress.completedStageIds, stage.id},
        rewardBalances: balances,
      );
      await _localDataSource.save(updated);
      return CampaignStageCompletion(
        progress: updated,
        wasFirstCompletion: true,
      );
    });
  }

  Future<T> _serialize<T>(Future<T> Function() operation) {
    final result = _pendingOperation.then((_) => operation());
    _pendingOperation = result.then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {},
    );
    return result;
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
