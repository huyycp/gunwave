import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/data_sources/remote/api/supabase_api.dart';
import 'package:gunwave/data/models/map_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final mapRemoteProvider = Provider<MapRemoteDataSource>((ref) {
  return MapRemoteDataSource(ref.read(supabaseApiProvider));
});

class MapRemoteDataSource {
  
  MapRemoteDataSource(this._supabaseApi);

  final SupabaseApi _supabaseApi;

  SupabaseClient get client => _supabaseApi.supabase;

  final mapsTable = 'maps';

  Future<List<MapModel>> getMaps() async {
    final response = await client
      .from(mapsTable)
      .select('*, monsters(*)') 
      .order('id', ascending: true);
    debugPrint("Maps response: $response");
    return response.map((json) {
      return MapModel.fromJson(json);
    }).toList();
  }
}