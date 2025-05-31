import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/dtos/req/create_room_req.dart';
import 'package:gunwave/data/models/map_model.dart';
import 'package:gunwave/repositories/map_repository.dart';
import 'package:gunwave/repositories/room_repository.dart';
import 'package:gunwave/utils/exception/app_exception.dart';
import 'package:gunwave/widgets/base/base_view_model.dart';

class CreateRoomViewModel extends BaseViewModel {
  CreateRoomViewModel(ChangeNotifierProviderRef ref, this.onSuccess) {
    _mapRepo = ref.read(mapRepoProvider);
    _roomRepo = ref.read(roomRepoProvider);
  }

  late final MapRepository _mapRepo;
  late final RoomRepository _roomRepo;

  final void Function(bool) onSuccess;

  final nameController = TextEditingController();
  final nameStatesController = WidgetStatesController();

  List<MapModel> maps = [];
  int currentMapIndex = 0;

  bool isPrivate = false;

  List<CreateQuizReq> quizzes = [];

  bool isLoading = true;
  bool isCreating = false;

  Future<void> getMaps() async {
    try {
      setLoading(true);
      maps = await _mapRepo.getMaps();
    } catch (err, stack) {
      AppException.log(runtimeType, err, stack);
    } finally {
      setLoading(false);
    }
  }

  void selectMap(int index) {
    if (index < 0 || index >= maps.length) return;
    currentMapIndex = index;
    notifyListeners();
  }

  void togglePrivate() {
    isPrivate = !isPrivate;
    notifyListeners();
  }

  void addQuiz(CreateQuizReq quiz) {
    quizzes.add(quiz);
    notifyListeners();
  }

  void setLoading(bool loading) {
    if (isLoading == loading) return;
    isLoading = loading;
    notifyListeners();
  }

  Future<void> createRoom() async {
    try {
      isCreating = true;
      notifyListeners();
      final req = CreateRoomReq(
        mapId: maps[currentMapIndex].id,
        userId: userRepo.appUser!.id,
        name: nameController.text,
        private: isPrivate,
        quizzes: quizzes,
      );
      await _roomRepo.createRoom(req);
      onSuccess(true);
    } catch (err, stack) {
      AppException.log(runtimeType, err, stack);
      onSuccess(false);
    } finally {
      isCreating = false;
      notifyListeners();
    }
  }
}