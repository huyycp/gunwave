import 'package:gunwave/data/models/character_model.dart';

/// Local campaign heroes keep solo play available without a remote profile.
abstract final class CampaignHeroCatalog {
  static const starter = CharacterModel(
    id: 'local_starter_warrior_blue',
    name: 'Blue Warrior',
    filename: 'warrior_blue',
    hp: 100,
    str: 10,
    vit: 3,
    agi: 4,
  );
}
