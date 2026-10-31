import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gunwave/data/models/character_model.dart';
import 'package:gunwave/data/models/room_model.dart';
import 'package:gunwave/data/models/user_model.dart';

part 'rank_model.freezed.dart';
part 'rank_model.g.dart';

// JsonKey applies to Freezed constructor parameters and is read by generation.
// ignore_for_file: invalid_annotation_target

/// Represents a player's result for a room, with linked user and game records.
@freezed
abstract class RankModel with _$RankModel {
  /// Creates an immutable rank entry.
  @JsonSerializable(explicitToJson: true)
  const factory RankModel({
    @Default('') String id,
    @JsonKey(
      name: 'user_id',
      readValue: _readUser,
      toJson: _userIdToJson,
    )
    required UserModel user,
    @JsonKey(
      name: 'room_id',
      readValue: _readRoom,
      toJson: _roomIdToJson,
    )
    required RoomModel room,
    @JsonKey(
      name: 'character_id',
      readValue: _readCharacter,
      toJson: _characterIdToJson,
    )
    required CharacterModel character,
    @Default(0) int score,
    @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)
    @Default(Duration.zero)
    Duration duration,
    @JsonKey(name: 'created_at', fromJson: _dateTimeFromJson)
    required DateTime createdAt,
  }) = _RankModel;

  /// Parses a rank row, accepting either linked records or foreign-key values.
  factory RankModel.fromJson(Map<String, dynamic> json) => _$RankModelFromJson({
        ...json,
        'users': json['users'] ?? {'id': json['user_id']},
        'rooms': json['rooms'] ?? {'id': json['room_id']},
        'characters': json['characters'] ?? {'id': json['character_id']},
      });
}

Duration _durationFromJson(Object? value) =>
    Duration(seconds: int.tryParse(value?.toString() ?? '') ?? 0);

int _durationToJson(Duration value) => value.inSeconds;

DateTime _dateTimeFromJson(Object? value) =>
    DateTime.tryParse(value?.toString() ?? '') ??
    DateTime.fromMillisecondsSinceEpoch(0);

Object? _readUser(Map json, String key) =>
    json['users'] ?? {'id': json['user_id']};

Object? _readRoom(Map json, String key) =>
    json['rooms'] ?? {'id': json['room_id']};

Object? _readCharacter(Map json, String key) =>
    json['characters'] ?? {'id': json['character_id']};

String _userIdToJson(UserModel value) => value.id;

String _roomIdToJson(RoomModel value) => value.id;

String _characterIdToJson(CharacterModel value) => value.id;
