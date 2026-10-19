import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/models/rank_model.dart';
import 'package:gunwave/repositories/rank_repository.dart';
import 'package:gunwave/widgets/base/base_view_model.dart';

final rankViewModel = ChangeNotifierProvider.autoDispose<RankViewModel>((ref) {
  return RankViewModel(ref);
});

class RankViewModel extends BaseViewModel {
  RankViewModel(ChangeNotifierProviderRef ref) {
    _rankRepo = ref.read(rankRepoProvider);
  }

  late final RankRepository _rankRepo;

  List<RankModel> ranks = [];
  bool isLoading = true;
  bool hasError = false;
  bool _isDisposed = false;

  Future<void> getRanks({String? roomId, String? userId}) async {
    if (_isDisposed) return;
    isLoading = true;
    hasError = false;
    notifyListeners();
    try {
      ranks = await _rankRepo.getRanksByRoom(roomId: roomId, userId: userId);
    } catch (error) {
      if (_isDisposed) return;
      hasError = true;
    } finally {
      if (!_isDisposed) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
