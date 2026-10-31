import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

// JsonKey applies to Freezed constructor parameters and is read by generation.
// ignore_for_file: invalid_annotation_target

/// Holds the app profile and its in-game gold balance.
@freezed
abstract class UserModel with _$UserModel {
  /// Creates an immutable app-user snapshot.
  const factory UserModel({
    @Default('') String id,
    @Default('') String name,
    @JsonKey(name: 'auth_id') @Default('') String authId,
    @Default(0) int gold,
  }) = _UserModel;

  /// Parses a user row using the database's `auth_id` column.
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
