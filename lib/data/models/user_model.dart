import 'package:gunwave/data/models/character_model.dart';
import 'package:gunwave/utils/common_functions.dart';
import 'package:gunwave/utils/list_utils.dart';

class UserModel {
  UserModel({
    required this.id,
    required this.name,
    required this.authId,
    required this.characters,
    required this.gold,
  });

  final String id;

  final String name;
  
  // Refers to supabase user id
  final String authId;

  final List<CharacterModel> characters;

  int gold;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    authId: json['auth_id']?.toString() ?? '',
    characters: listFromJson(json['characters'], (js) => CharacterModel.fromJson(js)),
    gold: intFromJson(json['gold']),
  );
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'auth_id': authId,
    'characters': characters.map((e) => e.toJson()).toList(),
    'gold': gold,
  };
}