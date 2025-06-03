import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/models/character_model.dart';
import 'package:gunwave/data/models/room_model.dart';
import 'package:gunwave/repositories/room_repository.dart';
import 'package:gunwave/widgets/base/base_view_model.dart';

final roomViewModel = ChangeNotifierProvider<RoomViewModel>(
  (ref) => RoomViewModel(ref)
);

class RoomViewModel extends BaseViewModel {
  RoomViewModel(ChangeNotifierProviderRef ref) {
    _roomRepo = ref.read(roomRepoProvider);
  }

  late final RoomRepository _roomRepo;

  List<RoomModel> rooms = [];
  int currentMapIndex = 0;
  CharacterModel? selectedCharacter;

  bool isLoading = true;

  void selectCharacter(CharacterModel character) {
    selectedCharacter = character;
    debugPrint("Character selected: ${character.name}");
  }

  void setLoading(bool loading) {
    isLoading = loading;
    notifyListeners();
  }

  Future<void> getRooms() async {
    if (rooms.isEmpty && !isLoading) setLoading(true);
    try {
      rooms = await _roomRepo.getRooms();
      debugPrint("Rooms loaded: ${rooms.map((e) => e.toJson())}");
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading rooms: $e");
    } finally {
      setLoading(false);
    }
  }
}