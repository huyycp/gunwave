import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/data/models/rank_model.dart';

void main() {
  test('RankModel JSON preserves identifiers, score, and duration units', () {
    final rank = RankModel.fromJson({
      'id': 'rank-1',
      'user_id': 'user-1',
      'room_id': 'room-1',
      'character_id': 'character-1',
      'score': 275,
      'duration': 83,
      'created_at': '2026-10-18T12:00:00Z',
    });

    final json = rank.toJson();
    final restored = RankModel.fromJson(json);

    expect(json['duration'], 83);
    expect(restored.id, 'rank-1');
    expect(restored.user.id, 'user-1');
    expect(restored.room.id, 'room-1');
    expect(restored.character.id, 'character-1');
    expect(restored.score, 275);
    expect(restored.duration, const Duration(seconds: 83));
  });
}
