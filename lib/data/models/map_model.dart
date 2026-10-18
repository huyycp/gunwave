import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gunwave/data/constants/game/game_map.dart';
import 'package:gunwave/data/models/monster_model.dart';
import 'package:gunwave/data/models/quiz_model.dart';
import 'package:gunwave/data/models/reward_model.dart';
import 'package:gunwave/utils/common_functions.dart';

// JsonKey applies to Freezed constructor parameters and is read by generation.
// ignore_for_file: invalid_annotation_target

part 'map_model.freezed.dart';
part 'map_model.g.dart';

/// Holds a map's metadata and the monsters, rewards, and questions it contains.
@freezed
abstract class MapModel with _$MapModel {
  const MapModel._();

  /// Creates an immutable map definition.
  @JsonSerializable(explicitToJson: true)
  const factory MapModel({
    @Default('') String id,
    @Default('') String name,
    @Default('') String filename,
    @JsonKey(name: 'time_limit') @Default(0) int timeLimit,
    @Default(<MonsterModel>[]) List<MonsterModel> monsters,
    @Default(<RewardModel>[]) List<RewardModel> rewards,
    @Default(<QuizModel>[]) List<QuizModel> questions,
  }) = _MapModel;

  /// Parses a map row and its nested game content.
  factory MapModel.fromJson(Map<String, dynamic> json) =>
      _$MapModelFromJson(json);

  /// Resolves [filename] to the matching in-game map asset.
  GameMaps? get map => mapFromFile(filename);
}
