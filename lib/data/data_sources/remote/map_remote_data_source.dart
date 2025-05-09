import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/data_sources/remote/api/supabase_api.dart';

final mapRemoteProvider = Provider<MapRemoteDataSource>((ref) {
  return MapRemoteDataSource(ref.read(supabaseApiProvider));
});

class MapRemoteDataSource {
  
  MapRemoteDataSource(this._supabaseApi);

  final SupabaseApi _supabaseApi;
}