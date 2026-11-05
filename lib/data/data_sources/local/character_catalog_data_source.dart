import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:gunwave/data/constants/game/game_character.dart';
import 'package:gunwave/data/models/ability_model.dart';
import 'package:gunwave/data/models/character_model.dart';

/// Supplies the bundled static hero and ability definitions.
abstract interface class CharacterCatalogDataSource {
  /// Loads and validates the complete local catalog.
  Future<CharacterCatalogContent> loadCatalog();
}

/// Character and ability rows loaded from the app's catalog assets.
class CharacterCatalogContent {
  /// Creates catalog content from its two related tables.
  const CharacterCatalogContent({
    required this.abilities,
    required this.characters,
  });

  /// Ability definitions referenced by [characters].
  final List<AbilityModel> abilities;

  /// Heroes available in the local Shop.
  final List<CharacterModel> characters;
}

/// Describes malformed or incompatible bundled character catalog data.
class CharacterCatalogException implements Exception {
  /// Creates a readable catalog validation error.
  const CharacterCatalogException(this.message);

  /// Explains which catalog value could not be used.
  final String message;

  @override
  String toString() => 'CharacterCatalogException: $message';
}

/// Reads the versioned hero and ability catalog from Flutter assets.
class AssetCharacterCatalogDataSource implements CharacterCatalogDataSource {
  /// Creates a source backed by the registered asset bundle.
  AssetCharacterCatalogDataSource({AssetBundle? assetBundle})
    : _assetBundle = assetBundle ?? rootBundle;

  /// Bundled ability definitions exported from the static catalog.
  static const abilitiesAssetPath = 'assets/data/catalog/abilities.json';

  /// Bundled character definitions exported from the static catalog.
  static const charactersAssetPath = 'assets/data/catalog/characters.json';

  final AssetBundle _assetBundle;

  @override
  Future<CharacterCatalogContent> loadCatalog() async {
    final abilities = await _loadAbilities();
    final characters = await _loadCharacters();
    _validateCatalog(abilities, characters);
    return CharacterCatalogContent(
      abilities: List.unmodifiable(abilities),
      characters: List.unmodifiable(characters),
    );
  }

  Future<List<AbilityModel>> _loadAbilities() async {
    final rows = await _loadRows(abilitiesAssetPath, 'abilities');
    return rows
        .map((row) {
          _requireFields(row, const [
            'id',
            'key',
            'name',
            'description',
            'cooldown_ms',
            'duration_ms',
            'parameters',
          ], abilitiesAssetPath);
          if (row['parameters'] is! Map<String, dynamic>) {
            throw const CharacterCatalogException(
              'Every ability parameters value must be a JSON object.',
            );
          }
          try {
            return AbilityModel.fromJson(row);
          } catch (error) {
            throw CharacterCatalogException(
              'Could not parse an ability in $abilitiesAssetPath: $error',
            );
          }
        })
        .toList(growable: false);
  }

  Future<List<CharacterModel>> _loadCharacters() async {
    final rows = await _loadRows(charactersAssetPath, 'characters');
    return rows
        .map((row) {
          _requireFields(row, const [
            'id',
            'name',
            'filename',
            'hp',
            'str',
            'vit',
            'agi',
            'price',
            'ability_id',
          ], charactersAssetPath);
          try {
            return CharacterModel.fromJson(row);
          } catch (error) {
            throw CharacterCatalogException(
              'Could not parse a character in $charactersAssetPath: $error',
            );
          }
        })
        .toList(growable: false);
  }

  Future<List<Map<String, dynamic>>> _loadRows(
    String path,
    String listKey,
  ) async {
    try {
      final decoded = jsonDecode(await _assetBundle.loadString(path));
      if (decoded is! Map<String, dynamic> || decoded[listKey] is! List) {
        throw CharacterCatalogException(
          '$path must contain a "$listKey" list.',
        );
      }
      return (decoded[listKey] as List)
          .map((entry) {
            if (entry is! Map) {
              throw CharacterCatalogException(
                'Every row in $path must be a JSON object.',
              );
            }
            return Map<String, dynamic>.from(entry);
          })
          .toList(growable: false);
    } on CharacterCatalogException {
      rethrow;
    } catch (error) {
      throw CharacterCatalogException('Could not read $path: $error');
    }
  }

  void _validateCatalog(
    List<AbilityModel> abilities,
    List<CharacterModel> characters,
  ) {
    if (abilities.isEmpty || characters.isEmpty) {
      throw const CharacterCatalogException(
        'The local character and ability catalogs must not be empty.',
      );
    }

    final abilityIds = <String>{};
    final abilityKeys = <String>{};
    for (final ability in abilities) {
      if (ability.id.isEmpty || !abilityIds.add(ability.id)) {
        throw CharacterCatalogException(
          'Ability IDs must be present and unique: "${ability.id}".',
        );
      }
      if (ability.key.isEmpty || !abilityKeys.add(ability.key)) {
        throw CharacterCatalogException(
          'Ability keys must be present and unique: "${ability.key}".',
        );
      }
      if (ability.name.isEmpty || ability.description.isEmpty) {
        throw CharacterCatalogException(
          'Ability "${ability.id}" must have a name and description.',
        );
      }
      if (ability.cooldownMs <= 0 ||
          (ability.durationMs != null && ability.durationMs! <= 0)) {
        throw CharacterCatalogException(
          'Ability "${ability.id}" has an invalid cooldown or duration.',
        );
      }
    }

    final characterIds = <String>{};
    for (final character in characters) {
      if (character.id.isEmpty || !characterIds.add(character.id)) {
        throw CharacterCatalogException(
          'Character IDs must be present and unique: "${character.id}".',
        );
      }
      if (character.name.isEmpty || character.filename.isEmpty) {
        throw CharacterCatalogException(
          'Character "${character.id}" must have a name and sprite filename.',
        );
      }
      if (!GameCharacters.values.any(
        (asset) => asset.name == character.filename,
      )) {
        throw CharacterCatalogException(
          'Character "${character.id}" references missing sprite '
          '"${character.filename}".',
        );
      }
      if (character.price < 0 ||
          character.hp <= 0 ||
          character.str <= 0 ||
          character.vit <= 0 ||
          character.agi <= 0) {
        throw CharacterCatalogException(
          'Character "${character.id}" has an invalid price or base stat.',
        );
      }
      if (character.abilityId != null &&
          !abilityIds.contains(character.abilityId)) {
        throw CharacterCatalogException(
          'Character "${character.id}" references missing ability '
          '"${character.abilityId}".',
        );
      }
    }
  }

  void _requireFields(
    Map<String, dynamic> row,
    List<String> fields,
    String path,
  ) {
    final missing = fields.where((field) => !row.containsKey(field)).toList();
    if (missing.isNotEmpty) {
      throw CharacterCatalogException(
        '$path row is missing required fields: ${missing.join(', ')}.',
      );
    }
  }
}
