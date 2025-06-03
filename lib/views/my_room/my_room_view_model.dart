import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/models/room_model.dart';
import 'package:gunwave/utils/exception/app_exception.dart';
import 'package:gunwave/widgets/base/base_view_model.dart';

final myRoomViewModel = ChangeNotifierProvider.autoDispose<MyRoomViewModel>((ref) {
  return MyRoomViewModel();
});

class MyRoomViewModel extends BaseViewModel {

  List<RoomModel> rooms = [];

  bool isLoading = true;

  Future<void> getMyRooms() async {
    try {
      setLoading(true);
      rooms = await userRepo.getMyRooms();
    } catch (err, stack) {
      AppException.log(runtimeType, err, stack);
    } finally {
      setLoading(false);
    }
  }

  void setLoading(bool loading) {
    if (isLoading == loading) return;
    isLoading = loading;
    notifyListeners();
  }
}