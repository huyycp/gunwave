import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:gunwave/data/models/campaign_stage_model.dart';

/// Provides campaign content stored in the app's bundled local assets.
abstract interface class CampaignContentDataSource {
  /// Loads all campaign stage definitions.
  Future<List<CampaignStageModel>> loadStages();
}

/// Reads stage definitions from the registered Flutter asset bundle.
class AssetCampaignContentDataSource implements CampaignContentDataSource {
  AssetCampaignContentDataSource({AssetBundle? assetBundle})
    : _assetBundle = assetBundle ?? rootBundle;

  /// Bundled JSON file containing the local campaign catalog.
  static const assetPath = 'assets/data/campaign/stages.json';

  final AssetBundle _assetBundle;

  @override
  Future<List<CampaignStageModel>> loadStages() async {
    try {
      final content = await _assetBundle.loadString(assetPath);
      final decoded = jsonDecode(content);
      if (decoded is! Map<String, dynamic> || decoded['stages'] is! List) {
        throw const CampaignContentException(
          'The campaign catalog must contain a stages list.',
        );
      }

      final stageJson = decoded['stages'] as List<dynamic>;
      return stageJson
          .map((entry) {
            if (entry is! Map) {
              throw const CampaignContentException(
                'Each campaign stage must be a JSON object.',
              );
            }
            return CampaignStageModel.fromJson(
              Map<String, dynamic>.from(entry),
            );
          })
          .toList(growable: false);
    } on CampaignContentException {
      rethrow;
    } catch (error) {
      throw CampaignContentException(
        'Could not read campaign content from $assetPath: $error',
      );
    }
  }
}

/// Describes invalid or unavailable bundled campaign content.
class CampaignContentException implements Exception {
  /// Creates a recoverable campaign content error with a readable [message].
  const CampaignContentException(this.message);

  /// Explains which part of the campaign content could not be used.
  final String message;

  @override
  String toString() => 'CampaignContentException: $message';
}
