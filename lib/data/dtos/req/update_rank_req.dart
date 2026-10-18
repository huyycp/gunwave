/// This class represents for the result when player completes a room
class UpdateRankReq {
  const UpdateRankReq({
    required this.roomId,
    required this.characterId,
    required this.timeLeft,
    required this.monsters,
    required this.quizzes,
  });

  final String roomId;

  final String characterId;

  final int timeLeft;

  final List<({String monsterId, double percentHpLeft})> monsters;

  final List<({String quizId, String answer, int failAttempts})> quizzes;

  Map<String, dynamic> toJson() {
    return {
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
}
