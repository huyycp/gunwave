import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/constants/game/game_map.dart';
import 'package:gunwave/widgets/base/base_view_model.dart';

final mapViewModel = ChangeNotifierProvider.autoDispose<MapViewModel>(
  (ref) => MapViewModel()
);

class MapViewModel extends BaseViewModel {

  GameMaps currentMap = GameMaps.values.first;

  void setMap(GameMaps map) {
    currentMap = map;
    debugPrint("Map changed to: ${currentMap.name}");
    notifyListeners();
  }
}