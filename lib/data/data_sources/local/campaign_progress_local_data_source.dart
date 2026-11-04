import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/models/campaign_progress_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

final campaignProgressLocalDataSourceProvider =
    Provider<CampaignProgressLocalDataSource>((ref) {
      return CampaignProgressLocalDataSource();
    });

/// Reads and writes the single serialized local campaign progress record.
class CampaignProgressLocalDataSource {
  CampaignProgressLocalDataSource({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const storageKey = 'campaign_progress_v1';

  final SharedPreferencesAsync _preferences;

  /// Returns an empty campaign record when no progress has been saved.
  Future<CampaignProgressModel> load() async {
    final serialized = await _preferences.getString(storageKey);
    if (serialized == null) return CampaignProgressModel();

    final decoded = jsonDecode(serialized);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'Campaign progress storage must contain a JSON object.',
      );
    }
    return CampaignProgressModel.fromJson(decoded);
  }

  /// Replaces the complete progress record in one preference write.
  Future<void> save(CampaignProgressModel progress) =>
      _preferences.setString(storageKey, jsonEncode(progress.toJson()));
}
