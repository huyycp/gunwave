import 'package:gunwave/data/constants/game/game_map.dart';
import 'package:gunwave/data/models/monster_model.dart';
import 'package:gunwave/data/models/reward_model.dart';
import 'package:gunwave/utils/common_functions.dart';
import 'package:gunwave/utils/list_utils.dart';

class MapModel {
  MapModel({
    required this.id,
    required this.name,
    required this.filename,
    required this.monsters,
    required this.rewards,
  });

  final String id;
  final String name;
  final String filename;
  final List<MonsterModel> monsters;
  final List<RewardModel> rewards;

  GameMaps? get map => mapFromFile(filename);

  factory MapModel.fromJson(Map<String, dynamic> json) => MapModel(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    filename: json['filename']?.toString() ?? '',
    monsters: listFromJson(json['monsters'], (js) => MonsterModel.fromJson(js)),
    rewards: listFromJson(json['rewards'], (js) => RewardModel.fromJson(js)),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'filename': filename,
    'monsters': monsters.map((e) => e.toJson()).toList(),
    'rewards': rewards.map((e) => e.toJson()).toList(),
  };
}