import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/data_sources/remote/rank_remote_data_source.dart';
import 'package:gunwave/data/dtos/req/update_rank_req.dart';
import 'package:gunwave/data/models/rank_model.dart';

final rankRepoProvider = Provider<RankRepository>((ref) {
  return RankRepository(ref.read(rankRemoteProvider));
});

class RankRepository {
  RankRepository(this._rankRemote);

  final RankRemoteDataSource _rankRemote;

  Future<RankModel> updateUserRank(UpdateRankReq req) async {
    return await _rankRemote.updateUserRank(req);
  }
}