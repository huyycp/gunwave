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

  Future<void> getRanks({String? roomId}) async {
    ranks = await _rankRepo.getRanksByRoom(roomId: roomId);
    notifyListeners();
  }
}