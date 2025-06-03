import 'package:gunwave/data/constants/game/game_map.dart';
import 'package:gunwave/data/models/monster_model.dart';
import 'package:gunwave/data/models/quiz_model.dart';
import 'package:gunwave/data/models/reward_model.dart';
import 'package:gunwave/utils/common_functions.dart';
import 'package:gunwave/utils/list_utils.dart';

class MapModel {
  MapModel({
    required this.id,
    required this.name,
    required this.filename,
    required this.timeLimit,
    required this.monsters,
    required this.rewards,
    required this.questions,
  });

  final String id;
  final String name;
  final String filename;
  final int timeLimit;
  final List<MonsterModel> monsters;
  final List<RewardModel> rewards;
  final List<QuizModel> questions;

  GameMaps? get map => mapFromFile(filename);

  factory MapModel.fromJson(Map<String, dynamic> json) => MapModel(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    filename: json['filename']?.toString() ?? '',
    timeLimit: intFromJson(json['time_limit']),
    monsters: listFromJson(json['monsters'], (js) => MonsterModel.fromJson(js)),
    rewards: listFromJson(json['rewards'], (js) => RewardModel.fromJson(js)),
    questions: listFromJson(json['questions'], (js) => QuizModel.fromJson(js)),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'filename': filename,
    'time_limit': timeLimit,
    'monsters': monsters.map((e) => e.toJson()).toList(),
    'rewards': rewards.map((e) => e.toJson()).toList(),
    'questions': questions.map((e) => e.toJson()).toList(),
  };
}