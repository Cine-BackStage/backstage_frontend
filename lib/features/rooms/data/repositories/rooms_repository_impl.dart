import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/room.dart';
import '../../domain/repositories/rooms_repository.dart';
import '../datasources/rooms_remote_datasource.dart';

class RoomsRepositoryImpl implements RoomsRepository {
  final RoomsRemoteDataSource remoteDataSource;

  RoomsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Room>>> getRooms({
    bool? isActive,
    RoomType? roomType,
  }) async {
    try {
      final rooms = await remoteDataSource.getRooms(
        isActive: isActive,
        roomType: roomType?.value,
      );
      return Right(rooms.map((model) => model.toEntity()).toList());
    } on DioException catch (e) {
      return Left(ErrorMapper.fromDioException(e));
    } catch (e) {
      return Left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Room>> getRoomById(String roomId) async {
    try {
      final room = await remoteDataSource.getRoomById(roomId);
      return Right(room.toEntity());
    } on DioException catch (e) {
      return Left(ErrorMapper.fromDioException(e));
    } catch (e) {
      return Left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Room>> createRoom({
    required String name,
    required int capacity,
    required RoomType roomType,
    String? seatMapId,
  }) async {
    try {
      final room = await remoteDataSource.createRoom(
        name: name,
        capacity: capacity,
        roomType: roomType.value,
        seatMapId: seatMapId,
      );
      return Right(room.toEntity());
    } on DioException catch (e) {
      return Left(ErrorMapper.fromDioException(e));
    } catch (e) {
      return Left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Room>> updateRoom({
    required String roomId,
    String? name,
    int? capacity,
    RoomType? roomType,
    String? seatMapId,
    bool? isActive,
  }) async {
    try {
      final room = await remoteDataSource.updateRoom(
        roomId: roomId,
        name: name,
        capacity: capacity,
        roomType: roomType?.value,
        seatMapId: seatMapId,
        isActive: isActive,
      );
      return Right(room.toEntity());
    } on DioException catch (e) {
      return Left(ErrorMapper.fromDioException(e));
    } catch (e) {
      return Left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRoom(String roomId, {bool permanent = false}) async {
    try {
      await remoteDataSource.deleteRoom(roomId, permanent: permanent);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ErrorMapper.fromDioException(e));
    } catch (e) {
      return Left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Room>> activateRoom(String roomId) async {
    try {
      final room = await remoteDataSource.activateRoom(roomId);
      return Right(room.toEntity());
    } on DioException catch (e) {
      return Left(ErrorMapper.fromDioException(e));
    } catch (e) {
      return Left(ErrorMapper.fromException(e));
    }
  }
}
