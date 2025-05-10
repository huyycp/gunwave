import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/data_sources/remote/map_remote_data_source.dart';
import 'package:gunwave/data/models/map_model.dart';

final mapRepoProvider = Provider<MapRepository>((ref) {
  return MapRepository(ref.read(mapRemoteProvider));
});

class MapRepository {
  MapRepository(this._mapRemote);

  final MapRemoteDataSource _mapRemote;

  Future<List<MapModel>> getMaps() async {
    return await _mapRemote.getMaps();
  }
}