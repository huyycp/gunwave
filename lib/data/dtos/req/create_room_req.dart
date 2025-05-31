class CreateRoomReq {
  CreateRoomReq({
    required this.mapId,
    required this.userId,
    required this.name,
    required this.private,
    required this.quizzes,
  });

  final String mapId;
  final String userId;
  final String name;
  final bool private;
  final List<CreateQuizReq> quizzes;

  Map<String, dynamic> toJson() {
    return {
      'map_id': mapId,
      'user_id': userId,
      'name': name,
      'private': private,
    };
  }
}

class CreateQuizReq {
  CreateQuizReq({
    required this.question,
    required this.resultA,
    required this.resultB,
    required this.resultC,
    required this.resultD,
    required this.answer,
  });

  final String question;
  final String resultA;
  final String resultB;
  final String resultC;
  final String resultD;
  final String answer;

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'result_a': resultA,
      'result_b': resultB,
      'result_c': resultC,
      'result_d': resultD,
      'answer': answer,
    };
  }
}