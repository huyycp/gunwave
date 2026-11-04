import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/data/models/stage_encounter_model.dart';

void main() {
  test('StageEncounterModel JSON round-trips spawn and enemy data', () {
    const encounter = StageEncounterModel(
      enemyId: 'elder_torch_boss',
      spawnMarker: 'torch_blue',
      count: 2,
    );

    final restored = StageEncounterModel.fromJson(encounter.toJson());

    expect(restored, encounter);
  });
}
