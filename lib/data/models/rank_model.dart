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
      user: UserModel.fromJson(
        json['users'] ?? {'id': json['user_id']},
      ),
      room: RoomModel.fromJson(
        json['rooms'] ?? {'id': json['room_id']},
      ),
      character: CharacterModel.fromCharactersJson(
        json['characters'] ?? {'id': json['character_id']},
      ),
      score: intFromJson(json['score']),
      duration: Duration(seconds: intFromJson(json['duration'])),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': user.id,
      'room_id': room.id,
      'character_id': character.id,
      'score': score,
      'duration': duration.inSeconds,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
