import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gunwave/data/models/stage_encounter_model.dart';

part 'stage_round_model.freezed.dart';
part 'stage_round_model.g.dart';

// JsonKey applies to Freezed constructor parameters and is read by generation.
// ignore_for_file: invalid_annotation_target

/// Describes one ordered encounter round within a campaign stage.
@freezed
abstract class StageRoundModel with _$StageRoundModel {
  /// Creates an immutable round definition.
  @JsonSerializable(explicitToJson: true)
  const factory StageRoundModel({
    @Default('') String id,
    @Default(0) int number,
    @Default(false) bool isBoss,
    @Default(<StageEncounterModel>[]) List<StageEncounterModel> encounters,
  }) = _StageRoundModel;

  /// Parses a round and its encounter groups from local campaign JSON.
  factory StageRoundModel.fromJson(Map<String, dynamic> json) =>
      _$StageRoundModelFromJson(json);
}
