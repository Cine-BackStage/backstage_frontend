import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/room.dart';

abstract class RoomsRepository {
  /// Get all rooms
  Future<Either<Failure, List<Room>>> getRooms({
    bool? isActive,
    RoomType? roomType,
  });

  /// Get room by ID
  Future<Either<Failure, Room>> getRoomById(String roomId);

  /// Create a new room
  Future<Either<Failure, Room>> createRoom({
    required String name,
    required int capacity,
    required RoomType roomType,
    String? seatMapId,
  });

  /// Update an existing room
  Future<Either<Failure, Room>> updateRoom({
    required String roomId,
    String? name,
    int? capacity,
    RoomType? roomType,
    String? seatMapId,
    bool? isActive,
  });

  /// Delete room (soft delete by default)
  Future<Either<Failure, void>> deleteRoom(String roomId, {bool permanent = false});

  /// Activate a deactivated room
  Future<Either<Failure, Room>> activateRoom(String roomId);
}
