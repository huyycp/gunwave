import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gunwave/data/constants/game/game_monster.dart';
import 'package:gunwave/utils/common_functions.dart';

part 'monster_model.freezed.dart';
part 'monster_model.g.dart';

/// Holds a monster's catalogue stats and score value.
@freezed
abstract class MonsterModel with _$MonsterModel {
  const MonsterModel._();

  /// Creates an immutable monster snapshot.
  const factory MonsterModel({
    @Default('') String id,
    @Default('') String name,
    @Default('') String filename,
    @Default(0) int hp,
    @Default(0) int str,
    @Default(0) int vit,
    @Default(0) int agi,
    @Default(0) int score,
  }) = _MonsterModel;

  /// Parses a monster row from Supabase JSON.
  factory MonsterModel.fromJson(Map<String, dynamic> json) =>
      _$MonsterModelFromJson(json);

  /// Resolves [filename] to the matching in-game monster asset.
  GameMonsters? get monster => monsterFromFile(filename);
}
