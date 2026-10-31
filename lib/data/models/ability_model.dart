import 'package:freezed_annotation/freezed_annotation.dart';

// JsonKey applies to Freezed constructor parameters and is read by generation.
// ignore_for_file: invalid_annotation_target

part 'ability_model.freezed.dart';
part 'ability_model.g.dart';

/// Describes a character ability and the values used by game logic.
/// Holds the ability metadata and JSON parameters stored in Supabase.
@freezed
abstract class AbilityModel with _$AbilityModel {
  /// Creates an immutable ability definition.
  const factory AbilityModel({
    @Default('') String id,
    @Default('') String key,
    @Default('') String name,
    @Default('') String description,
    @JsonKey(name: 'cooldown_ms') @Default(0) int cooldownMs,
    @JsonKey(name: 'duration_ms') int? durationMs,
    @Default(<String, dynamic>{}) Map<String, dynamic> parameters,
  }) = _AbilityModel;

  /// Parses an ability row, including its JSONB [parameters].
  factory AbilityModel.fromJson(Map<String, dynamic> json) =>
      _$AbilityModelFromJson(json);
}
