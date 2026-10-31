import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gunwave/utils/common_functions.dart';
import 'package:gunwave/utils/enum_utils.dart';

part 'reward_model.freezed.dart';
part 'reward_model.g.dart';

// JsonKey applies to Freezed constructor parameters and is read by generation.
// ignore_for_file: invalid_annotation_target

/// Represents a reward type and the amount granted by a map.
@freezed
abstract class RewardModel with _$RewardModel {
  /// Creates an immutable reward definition.
  const factory RewardModel({
    @Default('') String id,
    @JsonKey(fromJson: _rewardTypeFromJson, toJson: _rewardTypeToJson)
    @Default(RewardType.unknown)
    RewardType type,
    @Default(0) int amount,
  }) = _RewardModel;

  /// Parses a reward and reads its amount from a nested map-reward row.
  factory RewardModel.fromJson(Map<String, dynamic> json) =>
      _$RewardModelFromJson(_prepareRewardJson(json));
}

Map<String, dynamic> _prepareRewardJson(Map<String, dynamic> json) {
  final mapRewards = json['maps_rewards'];
  final amount = mapRewards is List && mapRewards.isNotEmpty
      ? mapRewards.first['amount']
      : json['amount'];
  return {...json, 'amount': intFromJson(amount)};
}

RewardType _rewardTypeFromJson(Object? value) =>
    enumFromString(RewardType.values, value?.toString(), RewardType.unknown);

String _rewardTypeToJson(RewardType value) => value.name;

/// Lists the reward kinds supported by the game.
enum RewardType {
  gold,
  sp,
  unknown,
}
