import 'package:gunwave/utils/common_functions.dart';
import 'package:gunwave/utils/enum_utils.dart';

class RewardModel {
  const RewardModel({
    required this.id,
    required this.type,
    required this.amount,
  });

  final String id;

  final RewardType type;
  
  final int amount;

  factory RewardModel.fromJson(Map<String, dynamic> json) => RewardModel(
    id: json['id']?.toString() ?? '',
    type: enumFromString(RewardType.values, json['type'], RewardType.unknown),
    amount: json['maps_rewards'] != null && json['maps_rewards'].isNotEmpty
      ? intFromJson(json['maps_rewards'].first['amount'])
      : 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'amount': amount,
  };
}

enum RewardType {
  gold,
  sp,
  unknown,
}