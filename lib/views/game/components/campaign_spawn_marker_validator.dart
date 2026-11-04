import 'package:gunwave/data/data_sources/local/campaign_content_data_source.dart';
import 'package:gunwave/data/models/campaign_stage_model.dart';

/// Verifies a stage's spawn references against names from its loaded Tiled map.
void validateCampaignSpawnMarkers(
  CampaignStageModel stage,
  Set<String> availableMarkerNames,
) {
  if (stage.map == null) {
    throw CampaignContentException(
      'Stage "${stage.id}" references unknown local map "${stage.mapKey}".',
    );
  }

  for (final round in stage.rounds) {
    for (final encounter in round.encounters) {
      if (!availableMarkerNames.contains(encounter.spawnMarker)) {
        throw CampaignContentException(
          'Stage "${stage.id}" round ${round.number} references missing Tiled spawn marker "${encounter.spawnMarker}".',
        );
      }
    }
  }
}
