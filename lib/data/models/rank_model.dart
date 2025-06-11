import 'package:gunwave/utils/common_functions.dart';

class RankModel {
  const RankModel({
    required this.id,
    required this.userId,
    required this.roomId,
    required this.characterId,
    required this.score,
    required this.duration,
    required this.createdAt,
  });

  final String id;
  
  final String userId;
  
  final String roomId;
  
  final String characterId;
  
  final int score;
  
  final Duration duration;
  
  final DateTime createdAt;

  factory RankModel.fromJson(Map<String, dynamic> json) {
    return RankModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      roomId: json['room_id'] ?? '',
      characterId: json['character_id'] ?? '',
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
      'user_id': userId,
      'room_id': roomId,
      'character_id': characterId,
      'score': score,
      'duration': duration.inMilliseconds,
      'created_at': createdAt.toIso8601String(),
    };
  }
}