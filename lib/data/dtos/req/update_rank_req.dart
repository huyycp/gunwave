import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_rank_req.freezed.dart';

/// Describes the result payload submitted when a player completes a room.
/// Holds the room-completion data submitted to the rank endpoint.
@Freezed(fromJson: false, toJson: false)
abstract class UpdateRankReq with _$UpdateRankReq {
  /// Creates an immutable rank submission with remaining monster and quiz data.
  const factory UpdateRankReq({
    required String roomId,
    required String characterId,
    required int timeLeft,
    required List<({String monsterId, double percentHpLeft})> monsters,
    required List<({String quizId, String answer, int failAttempts})> quizzes,
  }) = _UpdateRankReq;
}

extension UpdateRankReqJson on UpdateRankReq {
  /// Converts the submission to the nested JSON payload expected by the API.
  Map<String, dynamic> toJson() => {
        'room_id': roomId,
        'character_id': characterId,
        'time_left': timeLeft,
        'monsters': monsters
            .map((monster) => {
                  'monster_id': monster.monsterId,
                  'percent_hp_left': monster.percentHpLeft,
                })
            .toList(),
        'quizzes': quizzes
            .map((quiz) => {
                  'quiz_id': quiz.quizId,
                  'answer': quiz.answer,
                  'fail_attempts': quiz.failAttempts,
                })
            .toList(),
      };
}
