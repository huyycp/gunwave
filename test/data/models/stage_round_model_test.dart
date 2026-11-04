import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/data/models/stage_encounter_model.dart';
import 'package:gunwave/data/models/stage_round_model.dart';

void main() {
  test('StageRoundModel JSON round-trips ordered boss encounter data', () {
    const round = StageRoundModel(
      id: 'stage_1_round_5',
      number: 5,
      isBoss: true,
      encounters: [
        StageEncounterModel(
          enemyId: 'elder_torch_boss',
          spawnMarker: 'torch_blue',
        ),
      ],
    );

    final restored = StageRoundModel.fromJson(round.toJson());

    expect(restored, round);
  });
}
