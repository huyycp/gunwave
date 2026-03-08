import 'package:gunwave/data/models/character_model.dart';
import 'package:gunwave/data/models/room_model.dart';
import 'package:gunwave/data/models/user_model.dart';
import 'package:gunwave/utils/common_functions.dart';

class RankModel {
  const RankModel({
    required this.id,
    required this.user,
    required this.room,
    required this.character,
    required this.score,
    required this.duration,
    required this.createdAt,
  });

  final String id;
  
  final UserModel user;
  
  final RoomModel room;
  
  final CharacterModel character;
  
  final int score;
  
  final Duration duration;
  
  final DateTime createdAt;

  factory RankModel.fromJson(Map<String, dynamic> json) {
    return RankModel(
      id: json['id'] ?? '',
      user: UserModel.fromJson(json['users'] ?? {}),
      room: RoomModel.fromJson(json['rooms'] ?? {}),
      character: CharacterModel.fromCharactersJson(json['characters'] ?? {}),
      score: intFromJson(json['score']),
      duration: Duration(seconds: json['duration'] ?? 0),
      createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at']) 
        : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'room': room.toJson(),
      'character': character.toJson(),
      'score': score,
      'duration': duration.inMilliseconds,
      'created_at': createdAt.toIso8601String(),
    };
  }
}