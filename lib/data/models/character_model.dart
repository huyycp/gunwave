import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gunwave/data/constants/game/game_character.dart';
import 'package:gunwave/data/models/ability_model.dart';
import 'package:gunwave/utils/common_functions.dart';

// JsonKey applies to Freezed constructor parameters and is read by generation.
// ignore_for_file: invalid_annotation_target

part 'character_model.freezed.dart';
part 'character_model.g.dart';

/// Combines a character's catalogue stats with an optional special ability.
@freezed
abstract class CharacterModel with _$CharacterModel {
  const CharacterModel._();

  /// Creates an immutable character snapshot.
  @JsonSerializable(explicitToJson: true)
  const factory CharacterModel({
    @Default('') String id,
    @Default('') String name,
    @Default('') String filename,
    @Default(0) int price,
    @Default(0) int hp,
    @Default(0) int str,
    @Default(0) int vit,
    @Default(0) int agi,
    @Default(0) int sp,
    @JsonKey(name: 'ability_id') String? abilityId,
    @JsonKey(name: 'abilities') AbilityModel? ability,
  }) = _CharacterModel;

  /// Parses a character row and its optional [ability] relation.
  factory CharacterModel.fromJson(Map<String, dynamic> json) =>
      _$CharacterModelFromJson(json);

  /// Reads a row from the characters catalogue.
  factory CharacterModel.fromCharactersJson(Map<String, dynamic> json) =>
      CharacterModel.fromJson(json);

  /// Combines an owned-character row with its related catalogue row.
  factory CharacterModel.fromUsersCharactersJson(Map<String, dynamic> json) {
    final character = Map<String, dynamic>.from(
      json['characters'] as Map? ?? const <String, dynamic>{},
    );
    return CharacterModel.fromJson({
      ...character,
      'id': json['character_id'] ?? character['id'],
      'hp': json['hp'],
      'str': json['str'],
      'vit': json['vit'],
      'agi': json['agi'],
      'sp': json['sp'],
    });
  }

  /// Resolves [filename] to the matching in-game character asset.
  GameCharacters? get character => characterFromFile(filename);
}

/// Lists the character attributes that can be upgraded.
enum CharacterAttr {
  hp,
  str,
  vit,
  agi,
}
