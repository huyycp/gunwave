import 'package:freezed_annotation/freezed_annotation.dart';

part 'stage_encounter_model.freezed.dart';
part 'stage_encounter_model.g.dart';

/// Describes a group of enemies spawned at a named Tiled object.
@freezed
abstract class StageEncounterModel with _$StageEncounterModel {
  /// Creates an immutable encounter definition.
  const factory StageEncounterModel({
    @Default('') String enemyId,
    @Default('') String spawnMarker,
    @Default(1) int count,
  }) = _StageEncounterModel;

  /// Parses an encounter from local campaign JSON.
  factory StageEncounterModel.fromJson(Map<String, dynamic> json) =>
      _$StageEncounterModelFromJson(json);
}
