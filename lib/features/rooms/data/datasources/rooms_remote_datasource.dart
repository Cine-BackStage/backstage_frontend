import '../../../../adapters/http/http_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/room_model.dart';

abstract class RoomsRemoteDataSource {
  Future<List<RoomModel>> getRooms({
    bool? isActive,
    String? roomType,
  });
  Future<RoomModel> getRoomById(String roomId);
  Future<RoomModel> createRoom({
    required String name,
    required int capacity,
    required String roomType,
    String? seatMapId,
  });
  Future<RoomModel> updateRoom({
    required String roomId,
    String? name,
    int? capacity,
    String? roomType,
    String? seatMapId,
    bool? isActive,
  });
  Future<void> deleteRoom(String roomId, {bool permanent = false});
  Future<RoomModel> activateRoom(String roomId);
}

class RoomsRemoteDataSourceImpl implements RoomsRemoteDataSource {
  final HttpClient client;

  RoomsRemoteDataSourceImpl(this.client);

  @override
  Future<List<RoomModel>> getRooms({
    bool? isActive,
    String? roomType,
  }) async {
    final queryParams = <String, dynamic>{};

    if (isActive != null) {
      queryParams['isActive'] = isActive.toString();
    }

    if (roomType != null) {
      queryParams['roomType'] = roomType;
    }

    final response = await client.get(
      ApiConstants.rooms,
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );
    final data = response.data['data'] as List;
    return data.map((json) => RoomModel.fromJson(json)).toList();
  }

  @override
  Future<RoomModel> getRoomById(String roomId) async {
    final response = await client.get(ApiConstants.roomDetails(roomId));
    return RoomModel.fromJson(response.data['data']);
  }

  @override
  Future<RoomModel> createRoom({
    required String name,
    required int capacity,
    required String roomType,
    String? seatMapId,
  }) async {
    final response = await client.post(
      ApiConstants.rooms,
      data: {
        'name': name,
        'capacity': capacity,
        'roomType': roomType,
        if (seatMapId != null) 'seatMapId': seatMapId,
      },
    );
    return RoomModel.fromJson(response.data['data']);
  }

  @override
  Future<RoomModel> updateRoom({
    required String roomId,
    String? name,
    int? capacity,
    String? roomType,
    String? seatMapId,
    bool? isActive,
  }) async {
    final response = await client.put(
      ApiConstants.roomDetails(roomId),
      data: {
        if (name != null) 'name': name,
        if (capacity != null) 'capacity': capacity,
        if (roomType != null) 'roomType': roomType,
        if (seatMapId != null) 'seatMapId': seatMapId,
        if (isActive != null) 'isActive': isActive,
      },
    );
    return RoomModel.fromJson(response.data['data']);
  }

  @override
  Future<void> deleteRoom(String roomId, {bool permanent = false}) async {
    final queryParams = permanent ? {'permanent': 'true'} : null;
    await client.delete(
      ApiConstants.roomDetails(roomId),
      queryParameters: queryParams,
    );
  }

  @override
  Future<RoomModel> activateRoom(String roomId) async {
    final response = await client.post(ApiConstants.roomActivate(roomId));
    return RoomModel.fromJson(response.data['data']);
  }
}
