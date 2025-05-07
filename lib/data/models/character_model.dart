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
  });

  final String id;

  final String userId;
  
  final String name;
  
  final String filename;
  
  final int hp;

  final int str;
  
  final int vit;
  
  final int agi;
  
  final int sp;

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
  };
}