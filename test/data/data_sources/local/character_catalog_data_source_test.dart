import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunwave/data/constants/game/game_character.dart';
import 'package:gunwave/data/data_sources/local/character_catalog_data_source.dart';
import 'package:gunwave/views/game/abilities/ability_registry.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads linked characters and abilities supported by the game', () async {
    final catalog = await AssetCharacterCatalogDataSource().loadCatalog();
    final abilityIds = catalog.abilities.map((ability) => ability.id).toSet();

    expect(catalog.characters, hasLength(8));
    expect(catalog.abilities, hasLength(8));
    for (final character in catalog.characters) {
      expect(
        GameCharacters.values.any((asset) => asset.name == character.filename),
        isTrue,
        reason: 'Missing sprite mapping for ${character.filename}',
      );
      final sprite = GameCharacters.values.singleWhere(
        (asset) => asset.name == character.filename,
      );
      await rootBundle.load(sprite.path);
      expect(abilityIds, contains(character.abilityId));
    }
    for (final ability in catalog.abilities) {
      expect(ability.parameters, isA<Map<String, dynamic>>());
      expect(
        AbilityRegistry.create(ability),
        isNotNull,
        reason: 'Unsupported local ability ${ability.key}',
      );
    }
  });

  test('rejects a character that links to a missing ability', () async {
    final source = AssetCharacterCatalogDataSource(
      assetBundle: _MapAssetBundle({
        AssetCharacterCatalogDataSource.abilitiesAssetPath: jsonEncode({
          'abilities': [
            {
              'id': 'ability-1',
              'key': 'bulwark',
              'name': 'Bulwark',
              'description': 'Reduce damage',
              'cooldown_ms': 1000,
              'duration_ms': 1000,
              'parameters': {'damage_reduction': 0.4},
            },
          ],
        }),
        AssetCharacterCatalogDataSource.charactersAssetPath: jsonEncode({
          'characters': [
            {
              'id': 'character-1',
              'name': 'Warrior',
              'filename': 'warrior_blue',
              'hp': 100,
              'str': 10,
              'vit': 10,
              'agi': 10,
              'price': 0,
              'ability_id': 'missing-ability',
            },
          ],
        }),
      }),
    );

    await expectLater(
      source.loadCatalog(),
      throwsA(
        isA<CharacterCatalogException>().having(
          (error) => error.message,
          'message',
          contains('missing ability'),
        ),
      ),
    );
  });
}

class _MapAssetBundle extends CachingAssetBundle {
  _MapAssetBundle(this._assets);

  final Map<String, String> _assets;

  @override
  Future<ByteData> load(String key) async {
    final source = _assets[key];
    if (source == null) throw StateError('Missing test asset $key');
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(source)));
  }
}
