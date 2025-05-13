import 'package:gunwave/data/constants/game/game_monster.dart';
import 'package:gunwave/utils/common_functions.dart';

class MonsterModel {
  MonsterModel({
    required this.id,
    required this.name,
    required this.filename,
    required this.hp,
    required this.str,
    required this.vit,
    required this.agi,
  });

  final String id;
  final String name;
  final String filename;
  int hp;
  int str;
  int vit;
  int agi;

  GameMonsters? get monster => monsterFromFile(filename);

  factory MonsterModel.fromJson(Map<String, dynamic> json) => MonsterModel(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    filename: json['filename']?.toString() ?? '',
    hp: intFromJson(json['hp'], defaultValue: 0),
    str: intFromJson(json['str'], defaultValue: 0),
    vit: intFromJson(json['vit'], defaultValue: 0),
    agi: intFromJson(json['agi'], defaultValue: 0),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'filename': filename,
    'hp': hp,
    'str': str,
    'vit': vit,
    'agi': agi,
  };
}