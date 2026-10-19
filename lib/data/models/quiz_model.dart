import 'package:freezed_annotation/freezed_annotation.dart';

part 'quiz_model.freezed.dart';
part 'quiz_model.g.dart';

// JsonKey applies to Freezed constructor parameters and is read by generation.
// ignore_for_file: invalid_annotation_target

/// Holds a quiz question, its four choices, and the correct answer.
@freezed
abstract class QuizModel with _$QuizModel {
  /// Creates an immutable quiz question.
  const factory QuizModel({
    @Default('') String id,
    @Default('') String question,
    @JsonKey(name: 'result_a') @Default('') String resultA,
    @JsonKey(name: 'result_b') @Default('') String resultB,
    @JsonKey(name: 'result_c') @Default('') String resultC,
    @JsonKey(name: 'result_d') @Default('') String resultD,
    @Default('') String answer,
  }) = _QuizModel;

  /// Parses a quiz row using the database's `result_a` through `result_d` keys.
  factory QuizModel.fromJson(Map<String, dynamic> json) =>
      _$QuizModelFromJson(json);
}
