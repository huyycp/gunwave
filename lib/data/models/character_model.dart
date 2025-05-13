import 'package:gunwave/data/constants/game/game_character.dart';
import 'package:gunwave/utils/common_functions.dart';

class CharacterModel {
  CharacterModel({
    required this.id,
    required this.name,
    required this.filename,
    required this.price,
    required this.hp,
    required this.str,
    required this.vit,
    required this.agi,
    required this.sp,
  });

  final String id;
  
  final String name;
  
  final String filename;

  final int price;
  
  int hp;

  int str;
  
  int vit;
  
  int agi;
  
  int sp;

  GameCharacters? get character => characterFromFile(filename);

  factory CharacterModel.fromCharactersJson(Map<String, dynamic> json) => CharacterModel(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    filename: json['filename']?.toString() ?? '',
    price: intFromJson(json['price'], defaultValue: 0),
    hp: intFromJson(json['hp'], defaultValue: 0),
    str: intFromJson(json['str'], defaultValue: 0),
    vit: intFromJson(json['vit'], defaultValue: 0),
    agi: intFromJson(json['agi'], defaultValue: 0),
    sp: intFromJson(json['sp'], defaultValue: 0),
  );

  factory CharacterModel.fromUsersCharactersJson(Map<String, dynamic> json) => CharacterModel(
    id: json['character_id']?.toString() ?? '',
    name: json['characters']?['name']?.toString() ?? '',
    filename: json['characters']?['filename']?.toString() ?? '',
    price: intFromJson(json['characters']?['price'], defaultValue: 0),
    hp: intFromJson(json['hp'], defaultValue: 0),
    str: intFromJson(json['str'], defaultValue: 0),
    vit: intFromJson(json['vit'], defaultValue: 0),
    agi: intFromJson(json['agi'], defaultValue: 0),
    sp: intFromJson(json['sp'], defaultValue: 0),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'filename': filename,
    'price': price,
    'hp': hp,
    'str': str,
    'vit': vit,
    'agi': agi,
    'sp': sp,
  };
}

enum CharacterAttr {
  hp,
  str,
  vit,
  agi,
}