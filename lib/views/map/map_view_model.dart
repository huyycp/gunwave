import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/models/character_model.dart';
import 'package:gunwave/data/models/map_model.dart';
import 'package:gunwave/repositories/map_repository.dart';
import 'package:gunwave/widgets/base/base_view_model.dart';

final mapViewModel = ChangeNotifierProvider<MapViewModel>(
  (ref) => MapViewModel(ref)
);

class MapViewModel extends BaseViewModel {
  MapViewModel(ChangeNotifierProviderRef ref) {
    _mapRepo = ref.read(mapRepoProvider);
  }

  late final MapRepository _mapRepo;

  List<MapModel> maps = [];
  int currentMapIndex = 0;
  CharacterModel? selectedCharacter;

  bool isLoading = false;

  void setMap(int index) {
    currentMapIndex = index;
    debugPrint("Map changed to: ${maps[index].name}");
    notifyListeners();
  }

  Future<void> getMaps() async {
    if (maps.isEmpty) setLoading(true);
    try {
      maps = await _mapRepo.getMaps();
      debugPrint("Maps loaded: ${maps.length}");
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading maps: $e");
    } finally {
      setLoading(false);
    }
  }

  void selectCharacter(CharacterModel character) {
    selectedCharacter = character;
    debugPrint("Character selected: ${character.name}");
    // notifyListeners();
  }

  void setLoading(bool loading) {
    isLoading = loading;
    notifyListeners();
  }
}