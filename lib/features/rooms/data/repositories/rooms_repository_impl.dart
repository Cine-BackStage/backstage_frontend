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
      print('📚 Rooms Repository: Getting rooms (isActive: $isActive, type: ${roomType?.value})');
      final rooms = await remoteDataSource.getRooms(
        isActive: isActive,
        roomType: roomType?.value,
      );
      print('✅ Rooms Repository: Fetched ${rooms.length} rooms');
      return Right(rooms.map((model) => model.toEntity()).toList());
    } on DioException catch (e) {
      print('❌ Rooms Repository: DioException - ${e.message}');
      return Left(ErrorMapper.fromDioException(e));
    } catch (e) {
      print('❌ Rooms Repository: Exception - $e');
      return Left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Room>> getRoomById(String roomId) async {
    try {
      print('📚 Rooms Repository: Getting room $roomId');
      final room = await remoteDataSource.getRoomById(roomId);
      print('✅ Rooms Repository: Room fetched successfully');
      return Right(room.toEntity());
    } on DioException catch (e) {
      print('❌ Rooms Repository: DioException - ${e.message}');
      return Left(ErrorMapper.fromDioException(e));
    } catch (e) {
      print('❌ Rooms Repository: Exception - $e');
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
      print('📚 Rooms Repository: Creating room $name');
      final room = await remoteDataSource.createRoom(
        name: name,
        capacity: capacity,
        roomType: roomType.value,
        seatMapId: seatMapId,
      );
      print('✅ Rooms Repository: Room created successfully');
      return Right(room.toEntity());
    } on DioException catch (e) {
      print('❌ Rooms Repository: DioException - ${e.message}');
      print('❌ Rooms Repository: Response: ${e.response?.data}');
      return Left(ErrorMapper.fromDioException(e));
    } catch (e) {
      print('❌ Rooms Repository: Exception - $e');
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
      print('📚 Rooms Repository: Updating room $roomId');
      final room = await remoteDataSource.updateRoom(
        roomId: roomId,
        name: name,
        capacity: capacity,
        roomType: roomType?.value,
        seatMapId: seatMapId,
        isActive: isActive,
      );
      print('✅ Rooms Repository: Room updated successfully');
      return Right(room.toEntity());
    } on DioException catch (e) {
      print('❌ Rooms Repository: DioException - ${e.message}');
      print('❌ Rooms Repository: Response: ${e.response?.data}');
      return Left(ErrorMapper.fromDioException(e));
    } catch (e) {
      print('❌ Rooms Repository: Exception - $e');
      return Left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRoom(String roomId, {bool permanent = false}) async {
    try {
      print('📚 Rooms Repository: Deleting room $roomId (permanent: $permanent)');
      await remoteDataSource.deleteRoom(roomId, permanent: permanent);
      print('✅ Rooms Repository: Room deleted successfully');
      return const Right(null);
    } on DioException catch (e) {
      print('❌ Rooms Repository: DioException - ${e.message}');
      print('❌ Rooms Repository: Response: ${e.response?.data}');
      return Left(ErrorMapper.fromDioException(e));
    } catch (e) {
      print('❌ Rooms Repository: Exception - $e');
      return Left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Room>> activateRoom(String roomId) async {
    try {
      print('📚 Rooms Repository: Activating room $roomId');
      final room = await remoteDataSource.activateRoom(roomId);
      print('✅ Rooms Repository: Room activated successfully');
      return Right(room.toEntity());
    } on DioException catch (e) {
      print('❌ Rooms Repository: DioException - ${e.message}');
      return Left(ErrorMapper.fromDioException(e));
    } catch (e) {
      print('❌ Rooms Repository: Exception - $e');
      return Left(ErrorMapper.fromException(e));
    }
  }
}
