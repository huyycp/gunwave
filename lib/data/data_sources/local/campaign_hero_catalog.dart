import 'package:gunwave/data/models/ability_model.dart';
import 'package:gunwave/data/models/character_model.dart';

/// Local campaign heroes keep solo play available without a remote profile.
abstract final class CampaignHeroCatalog {
  /// Stable ID from the bundled character catalog.
  static const starterId = '8f793e1f-7d76-4bb5-8175-e2d0e3510cfb';

  /// ID used by earlier local builds before the catalog export was available.
  static const legacyStarterId = 'local_starter_warrior_blue';

  /// Static fallback used only while local hero data is unavailable.
  static const starter = CharacterModel(
    id: starterId,
    name: 'Adept Warrior',
    filename: 'warrior_blue',
    price: 0,
    hp: 220,
    str: 20,
    vit: 10,
    agi: 120,
    abilityId: '1e0cbca4-6bba-4dbc-b2ac-5328f04d36ce',
    ability: AbilityModel(
      id: '1e0cbca4-6bba-4dbc-b2ac-5328f04d36ce',
      key: 'bulwark',
      name: 'Bulwark',
      description: 'Reduce incoming damage by 40%',
      cooldownMs: 14000,
      durationMs: 3000,
      parameters: {'damage_reduction': 0.4},
    ),
  );
}
