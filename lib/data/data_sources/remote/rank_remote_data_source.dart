import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/data_sources/remote/api/supabase_api.dart';
import 'package:gunwave/data/dtos/req/update_rank_req.dart';
import 'package:gunwave/data/models/rank_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final rankRemoteProvider = Provider<RankRemoteDataSource>((ref) {
  return RankRemoteDataSource(ref.read(supabaseApiProvider));
});

class RankRemoteDataSource {
  RankRemoteDataSource(this._supabaseApi);

  final SupabaseApi _supabaseApi;

  SupabaseClient get client => _supabaseApi.supabase;

  final ranksTable = 'ranks';

  Future<RankModel> updateUserRank(UpdateRankReq req) async {
    final session = client.auth.currentSession;
    if (session == null) {
      throw StateError(
          'Cannot submit a rank without an authenticated session.');
    }

    final resp = await client.functions.invoke(
      'update-ranks',
      headers: {
        'Authorization': 'Bearer ${session.accessToken}',
        'Content-Type': 'application/json',
      },
      body: req.toJson(),
    );
    if (resp.data is! Map) {
      throw const FormatException('Rank service returned an invalid response.');
    }
    return RankModel.fromJson(Map<String, dynamic>.from(resp.data as Map));
  }

  Future<List<RankModel>> getRanksByRoom(
      {String? roomId, String? userId}) async {
    var query = client.from(ranksTable).select(
          '*, users(*), characters(*, abilities(*)), rooms(*)',
        );
    if (roomId != null) {
      query = query.eq('room_id', roomId);
    }
    if (userId != null) {
      query = query.eq('user_id', userId);
    }
    final response = await query
        .order('score', ascending: false)
        .order('duration')
        .order('created_at');
    return List<RankModel>.from(
        response.map((json) => RankModel.fromJson(json)));
  }
}
