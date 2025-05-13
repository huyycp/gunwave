import 'package:gunwave/data/models/character_model.dart';
import 'package:gunwave/utils/list_utils.dart';

class UserModel {
  UserModel({
    required this.id,
    required this.name,
    required this.authId,
    required this.characters,
  });

  final String id;

  final String name;
  
  // Refers to supabase user id
  final String authId;

  final List<CharacterModel> characters;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    authId: json['auth_id']?.toString() ?? '',
    characters: listFromJson(json['characters'], (js) => CharacterModel.fromJson(js)),
  );
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'auth_id': authId,
    'characters': characters.map((e) => e.toJson()).toList(),
  };
}