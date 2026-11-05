import 'package:flutter/foundation.dart';
import 'package:gunwave/data/models/reward_model.dart';

/// Local campaign state read from this device's SQLite database.
@immutable
class CampaignProgressModel {
  CampaignProgressModel({
    Set<String> completedStageIds = const {},
    this.selectedHeroId,
    Map<String, int> rewardBalances = const {},
  }) : completedStageIds = Set.unmodifiable(completedStageIds),
       rewardBalances = Map.unmodifiable(rewardBalances) {
    if (this.completedStageIds.any((id) => id.trim().isEmpty)) {
      throw ArgumentError.value(
        completedStageIds,
        'completedStageIds',
        'Stage IDs must not be empty.',
      );
    }
    if (this.rewardBalances.values.any((amount) => amount < 0)) {
      throw ArgumentError.value(
        rewardBalances,
        'rewardBalances',
        'Reward balances must not be negative.',
      );
    }
    if (selectedHeroId != null && selectedHeroId!.trim().isEmpty) {
      throw ArgumentError.value(
        selectedHeroId,
        'selectedHeroId',
        'Hero IDs must not be empty.',
      );
    }
  }

  static const schemaVersion = 1;

  final Set<String> completedStageIds;
  final String? selectedHeroId;
  final Map<String, int> rewardBalances;

  /// Current local gold shared by campaign rewards and Shop purchases.
  int get goldBalance => balanceFor(RewardType.gold);

  /// Earned status points are kept with other local campaign rewards.
  int get statusPointBalance => balanceFor(RewardType.sp);

  /// Returns the saved balance for [type], or zero if no reward was earned.
  int balanceFor(RewardType type) => rewardBalances[type.name] ?? 0;

  CampaignProgressModel copyWith({
    Set<String>? completedStageIds,
    String? selectedHeroId,
    Map<String, int>? rewardBalances,
  }) => CampaignProgressModel(
    completedStageIds: completedStageIds ?? this.completedStageIds,
    selectedHeroId: selectedHeroId ?? this.selectedHeroId,
    rewardBalances: rewardBalances ?? this.rewardBalances,
  );

  /// Converts this record into a stable JSON representation.
  Map<String, Object?> toJson() => {
    'schemaVersion': schemaVersion,
    'completedStageIds': completedStageIds.toList()..sort(),
    'selectedHeroId': selectedHeroId,
    'rewardBalances': Map.fromEntries(
      rewardBalances.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    ),
  };

  /// Parses a persisted campaign record and rejects unknown schema versions.
  factory CampaignProgressModel.fromJson(Map<String, dynamic> json) {
    if (json['schemaVersion'] != schemaVersion) {
      throw FormatException(
        'Unsupported campaign progress schema: ${json['schemaVersion']}.',
      );
    }

    final rawCompletedStageIds = json['completedStageIds'];
    if (rawCompletedStageIds is! List ||
        rawCompletedStageIds.any((id) => id is! String)) {
      throw const FormatException(
        'Campaign progress completedStageIds must be a list of strings.',
      );
    }

    final rawSelectedHeroId = json['selectedHeroId'];
    if (rawSelectedHeroId != null && rawSelectedHeroId is! String) {
      throw const FormatException(
        'Campaign progress selectedHeroId must be a string or null.',
      );
    }

    final rawRewardBalances = json['rewardBalances'];
    if (rawRewardBalances is! Map ||
        rawRewardBalances.keys.any((key) => key is! String) ||
        rawRewardBalances.values.any((value) => value is! int)) {
      throw const FormatException(
        'Campaign progress rewardBalances must map strings to integers.',
      );
    }

    return CampaignProgressModel(
      completedStageIds: rawCompletedStageIds.cast<String>().toSet(),
      selectedHeroId: rawSelectedHeroId as String?,
      rewardBalances: rawRewardBalances.cast<String, int>(),
    );
  }
}

/// Result of applying a stage's one-time local rewards.
@immutable
class CampaignStageCompletion {
  const CampaignStageCompletion({
    required this.progress,
    required this.wasFirstCompletion,
  });

  final CampaignProgressModel progress;
  final bool wasFirstCompletion;
}
