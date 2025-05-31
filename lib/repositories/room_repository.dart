import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gunwave/data/data_sources/remote/room_remote_data_source.dart';
import 'package:gunwave/data/dtos/req/create_room_req.dart';
import 'package:gunwave/data/models/room_model.dart';

final roomRepoProvider = Provider<RoomRepository>((ref) {
  return RoomRepository(ref.read(roomRemoteProvider));
});

class RoomRepository {
  RoomRepository(this._roomRemote);

  final RoomRemoteDataSource _roomRemote;

  Future<List<RoomModel>> getRooms() {
    return _roomRemote.getRooms();
  }

  Future<void> createRoom(CreateRoomReq room) {
    return _roomRemote.createRoom(room);
  }
}