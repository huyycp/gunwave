import 'package:gunwave/data/constants/game/game_character.dart';
import 'package:gunwave/utils/common_functions.dart';

class CharacterModel {
  CharacterModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.filename,
    required this.hp,
    required this.str,
    required this.vit,
    required this.agi,
    required this.sp,
    required this.baseHp,
    required this.baseStr,
    required this.baseVit,
    required this.baseAgi,
    required this.totalSp,
  });

  final String id;

  final String userId;
  
  final String name;
  
  final String filename;
  
  int hp;

  int str;
  
  int vit;
  
  int agi;
  
  int sp;

  int baseHp;

  int baseStr;

  int baseVit;

  int baseAgi;

  int totalSp;

  GameCharacter? get character => characterFromFile(filename);

  factory CharacterModel.fromJson(Map<String, dynamic> json) => CharacterModel(
    id: json['id']?.toString() ?? '',
    userId: json['user_id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    filename: json['filename']?.toString() ?? '',
    hp: intFromJson(json['hp'], defaultValue: 0),
    str: intFromJson(json['str'], defaultValue: 0),
    vit: intFromJson(json['vit'], defaultValue: 0),
    agi: intFromJson(json['agi'], defaultValue: 0),
    sp: intFromJson(json['sp'], defaultValue: 0),
    baseHp: intFromJson(json['base_hp'], defaultValue: 0),
    baseStr: intFromJson(json['base_str'], defaultValue: 0),
    baseVit: intFromJson(json['base_vit'], defaultValue: 0),
    baseAgi: intFromJson(json['base_agi'], defaultValue: 0),
    totalSp: intFromJson(json['total_sp'], defaultValue: 0),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'name': name,
    'filename': filename,
    'hp': hp,
    'str': str,
    'vit': vit,
    'agi': agi,
    'sp': sp,
    'base_hp': baseHp,
    'base_str': baseStr,
    'base_vit': baseVit,
    'base_agi': baseAgi,
    'total_sp': totalSp,
  };
}

enum CharacterAttr {
  hp,
  str,
  vit,
  agi,
}