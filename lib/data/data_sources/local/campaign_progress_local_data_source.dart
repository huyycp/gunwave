import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/database/app_database.dart';
import 'package:gunwave/data/models/campaign_progress_model.dart';
import 'package:gunwave/data/models/campaign_stage_model.dart';
import 'package:gunwave/data/models/reward_model.dart';

final campaignProgressLocalDataSourceProvider =
    Provider<CampaignProgressLocalDataSource>((ref) {
      return CampaignProgressLocalDataSource(ref.read(appDatabaseProvider));
    });

/// Reads and mutates device-local campaign state in SQLite.
class CampaignProgressLocalDataSource {
  const CampaignProgressLocalDataSource(this._database);

  final AppDatabase _database;

  Future<CampaignProgressModel> load() => _loadProgress();

  Future<CampaignProgressModel> selectHero(String heroId) =>
      _database.transaction(() async {
        final owned = await (_database.select(
          _database.playerCharacters,
        )..where((row) => row.characterId.equals(heroId))).getSingleOrNull();
        if (owned == null) {
          throw ArgumentError.value(
            heroId,
            'heroId',
            'Only a locally owned hero can be selected.',
          );
        }
        await (_database.update(_database.playerStates)
              ..where((row) => row.id.equals(1)))
            .write(PlayerStatesCompanion(selectedHeroId: Value(heroId)));
        return _loadProgress();
      });

  Future<CampaignStageCompletion> completeStage(CampaignStageModel stage) =>
      _database.transaction(() async {
        final previousClear = await (_database.select(
          _database.campaignStageClears,
        )..where((row) => row.stageId.equals(stage.id))).getSingleOrNull();
        if (previousClear != null) {
          return CampaignStageCompletion(
            progress: await _loadProgress(),
            wasFirstCompletion: false,
          );
        }

        final state = await (_database.select(
          _database.playerStates,
        )..where((row) => row.id.equals(1))).getSingle();
        var gold = state.gold;
        var statusPoints = state.statusPoints;
        for (final reward in stage.rewards) {
          if (reward.amount < 0 || reward.type == RewardType.unknown) {
            throw ArgumentError.value(
              reward,
              'stage.rewards',
              'Rewards must use a known type and non-negative amount.',
            );
          }
          switch (reward.type) {
            case RewardType.gold:
              gold += reward.amount;
            case RewardType.sp:
              statusPoints += reward.amount;
            case RewardType.unknown:
              break;
          }
        }

        await _database
            .into(_database.campaignStageClears)
            .insert(
              CampaignStageClearsCompanion.insert(
                stageId: stage.id,
                completedAt: DateTime.now().millisecondsSinceEpoch,
              ),
            );
        await (_database.update(
          _database.playerStates,
        )..where((row) => row.id.equals(1))).write(
          PlayerStatesCompanion(
            gold: Value(gold),
            statusPoints: Value(statusPoints),
          ),
        );
        return CampaignStageCompletion(
          progress: await _loadProgress(),
          wasFirstCompletion: true,
        );
      });

  Future<CampaignProgressModel> _loadProgress() async {
    final state = await (_database.select(
      _database.playerStates,
    )..where((row) => row.id.equals(1))).getSingleOrNull();
    final clears = await _database.select(_database.campaignStageClears).get();
    final rewards = <String, int>{};
    if ((state?.gold ?? 0) > 0) rewards[RewardType.gold.name] = state!.gold;
    if ((state?.statusPoints ?? 0) > 0) {
      rewards[RewardType.sp.name] = state!.statusPoints;
    }
    return CampaignProgressModel(
      completedStageIds: clears.map((clear) => clear.stageId).toSet(),
      selectedHeroId: state?.selectedHeroId,
      rewardBalances: rewards,
    );
  }
}
