/// This class represents for the result when player completes a room
class UpdateRankReq {
  const UpdateRankReq({
    required this.roomId,
    required this.characterId,
    required this.timeLeft,
    required this.timeLimit,
    required this.monsters,
    required this.quizzes,
  }); 

  final String roomId;
  
  final String characterId;
  
  final int timeLeft;

  final int timeLimit;
  
  final List<({double percenHpLeft, int score})> monsters;
  
  final List<({int failAttempts, bool isCorrect})> quizzes;

  Map<String, dynamic> toJson() {
    return {
      'room_id': roomId,
      'character_id': characterId,
      'time_left': timeLeft,
      'time_limit': timeLimit,
      'monsters': monsters.map((m) => {'percent_hp_left': m.percenHpLeft, 'score': m.score}).toList(),
      'quizzes': quizzes.map((q) => {'fail_attempts': q.failAttempts, 'is_correct': q.isCorrect}).toList(),
    };
  }
}
