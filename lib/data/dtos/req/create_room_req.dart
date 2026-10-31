import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_room_req.freezed.dart';
part 'create_room_req.g.dart';

// JsonKey applies to Freezed constructor parameters and is read by generation.
// ignore_for_file: invalid_annotation_target

/// Holds the room fields sent to the room-creation endpoint.
@freezed
abstract class CreateRoomReq with _$CreateRoomReq {
  /// Creates a room request and its locally associated quiz requests.
  const factory CreateRoomReq({
    @JsonKey(name: 'map_id') required String mapId,
    @JsonKey(name: 'user_id') required String userId,
    required String name,
    required bool private,
    @JsonKey(includeToJson: false)
    @Default(<CreateQuizReq>[])
    List<CreateQuizReq> quizzes,
  }) = _CreateRoomReq;

  /// Parses a room-creation request from its snake-case JSON fields.
  factory CreateRoomReq.fromJson(Map<String, dynamic> json) =>
      _$CreateRoomReqFromJson(json);
}

/// Holds the question fields sent alongside a room-creation request.
@freezed
abstract class CreateQuizReq with _$CreateQuizReq {
  /// Creates a quiz request with four answer choices.
  const factory CreateQuizReq({
    required String question,
    @JsonKey(name: 'result_a') required String resultA,
    @JsonKey(name: 'result_b') required String resultB,
    @JsonKey(name: 'result_c') required String resultC,
    @JsonKey(name: 'result_d') required String resultD,
    required String answer,
  }) = _CreateQuizReq;

  /// Parses a quiz request from its snake-case JSON fields.
  factory CreateQuizReq.fromJson(Map<String, dynamic> json) =>
      _$CreateQuizReqFromJson(json);
}
