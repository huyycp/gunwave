class QuestionModel {
  QuestionModel({
    required this.id,
    required this.question,
    required this.resultA,
    required this.resultB,
    required this.resultC,
    required this.resultD,
    required this.answer,
  });

  final String id;
  final String question;
  final String resultA;
  final String resultB;
  final String resultC;
  final String resultD;
  final String answer;

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id']?.toString() ?? '',
      question: json['question']?.toString() ?? '',
      resultA: json['result_a']?.toString() ?? '',
      resultB: json['result_b']?.toString() ?? '',
      resultC: json['result_c']?.toString() ?? '',
      resultD: json['result_d']?.toString() ?? '',
      answer: json['answer']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'result_a': resultA,
      'result_b': resultB,
      'result_c': resultC,
      'result_d': resultD,
      'answer': answer,
    };
  }
}