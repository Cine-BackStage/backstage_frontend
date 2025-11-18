import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/room.dart';
import '../repositories/rooms_repository.dart';

// ============================================================================
// Get Rooms UseCase
// ============================================================================
abstract class GetRoomsUseCase {
  Future<Either<Failure, List<Room>>> call({
    bool? isActive,
    RoomType? roomType,
  });
}

class GetRoomsUseCaseImpl implements GetRoomsUseCase {
  final RoomsRepository repository;

  GetRoomsUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, List<Room>>> call({
    bool? isActive,
    RoomType? roomType,
  }) async {
    return await repository.getRooms(
      isActive: isActive,
      roomType: roomType,
    );
  }
}

// ============================================================================
// Get Room By ID UseCase
// ============================================================================
abstract class GetRoomByIdUseCase {
  Future<Either<Failure, Room>> call(String roomId);
}

class GetRoomByIdUseCaseImpl implements GetRoomByIdUseCase {
  final RoomsRepository repository;

  GetRoomByIdUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, Room>> call(String roomId) async {
    return await repository.getRoomById(roomId);
  }
}

// ============================================================================
// Create Room UseCase
// ============================================================================
class CreateRoomParams {
  final String name;
  final int capacity;
  final RoomType roomType;
  final String? seatMapId;

  CreateRoomParams({
    required this.name,
    required this.capacity,
    required this.roomType,
    this.seatMapId,
  });
}

abstract class CreateRoomUseCase {
  Future<Either<Failure, Room>> call(CreateRoomParams params);
}

class CreateRoomUseCaseImpl implements CreateRoomUseCase {
  final RoomsRepository repository;

  CreateRoomUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, Room>> call(CreateRoomParams params) async {
    return await repository.createRoom(
      name: params.name,
      capacity: params.capacity,
      roomType: params.roomType,
      seatMapId: params.seatMapId,
    );
  }
}

// ============================================================================
// Update Room UseCase
// ============================================================================
class UpdateRoomParams {
  final String roomId;
  final String? name;
  final int? capacity;
  final RoomType? roomType;
  final String? seatMapId;
  final bool? isActive;

  UpdateRoomParams({
    required this.roomId,
    this.name,
    this.capacity,
    this.roomType,
    this.seatMapId,
    this.isActive,
  });
}

abstract class UpdateRoomUseCase {
  Future<Either<Failure, Room>> call(UpdateRoomParams params);
}

class UpdateRoomUseCaseImpl implements UpdateRoomUseCase {
  final RoomsRepository repository;

  UpdateRoomUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, Room>> call(UpdateRoomParams params) async {
    return await repository.updateRoom(
      roomId: params.roomId,
      name: params.name,
      capacity: params.capacity,
      roomType: params.roomType,
      seatMapId: params.seatMapId,
      isActive: params.isActive,
    );
  }
}

// ============================================================================
// Delete Room UseCase
// ============================================================================
abstract class DeleteRoomUseCase {
  Future<Either<Failure, void>> call(String roomId, {bool permanent = false});
}

class DeleteRoomUseCaseImpl implements DeleteRoomUseCase {
  final RoomsRepository repository;

  DeleteRoomUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, void>> call(String roomId, {bool permanent = false}) async {
    return await repository.deleteRoom(roomId, permanent: permanent);
  }
}

// ============================================================================
// Activate Room UseCase
// ============================================================================
abstract class ActivateRoomUseCase {
  Future<Either<Failure, Room>> call(String roomId);
}

class ActivateRoomUseCaseImpl implements ActivateRoomUseCase {
  final RoomsRepository repository;

  ActivateRoomUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, Room>> call(String roomId) async {
    return await repository.activateRoom(roomId);
  }
}
