import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gunwave/data/models/map_model.dart';
import 'package:gunwave/data/models/quiz_model.dart';
import 'package:gunwave/data/models/user_model.dart';

part 'room_model.freezed.dart';
part 'room_model.g.dart';

// JsonKey applies to Freezed constructor parameters and is read by generation.
// ignore_for_file: invalid_annotation_target

/// Holds room visibility, ownership, map, and quiz data.
@freezed
abstract class RoomModel with _$RoomModel {
  /// Creates an immutable room snapshot.
  @JsonSerializable(explicitToJson: true)
  const factory RoomModel({
    @Default('') String id,
    @JsonKey(name: 'map_id') @Default('') String mapId,
    @JsonKey(name: 'user_id') @Default('') String userId,
    @Default('') String name,
    @Default(true) bool private,
    @JsonKey(
      name: 'created_at',
      fromJson: _createdAtFromJson,
      toJson: _createdAtToJson,
    )
    DateTime? createdAt,
    @JsonKey(name: 'maps') MapModel? map,
    @JsonKey(name: 'user', readValue: _readUser) UserModel? user,
    @Default(<QuizModel>[]) List<QuizModel> quizzes,
  }) = _RoomModel;

  /// Parses a room row and any nested map, user, and quiz records.
  factory RoomModel.fromJson(Map<String, dynamic> json) =>
      _$RoomModelFromJson(json);
}

DateTime? _createdAtFromJson(Object? value) =>
    value == null ? null : DateTime.tryParse(value.toString());

String _createdAtToJson(DateTime? value) => value?.toIso8601String() ?? '';

Object? _readUser(Map json, String key) => json['users'] ?? json['user'];
