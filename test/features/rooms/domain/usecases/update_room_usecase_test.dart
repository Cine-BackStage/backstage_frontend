import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/rooms/domain/entities/room.dart';
import 'package:backstage_frontend/features/rooms/domain/repositories/rooms_repository.dart';
import 'package:backstage_frontend/features/rooms/domain/usecases/room_usecases.dart';

class MockRoomsRepository extends Mock implements RoomsRepository {}

void main() {
  late UpdateRoomUseCaseImpl useCase;
  late MockRoomsRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(RoomType.twoD);
  });

  setUp(() {
    mockRepository = MockRoomsRepository();
    useCase = UpdateRoomUseCaseImpl(mockRepository);
  });

  const tRoomId = 'room-123';

  final tParams = UpdateRoomParams(
    roomId: tRoomId,
    name: 'Updated Room',
    capacity: 150,
    roomType: RoomType.threeD,
    seatMapId: 'seat-map-2',
    isActive: true,
  );

  final tRoom = Room(
    id: tRoomId,
    name: 'Updated Room',
    capacity: 150,
    roomType: RoomType.threeD,
    seatMapId: 'seat-map-2',
    isActive: true,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 2),
  );

  test('should call repository.updateRoom with all parameters', () async {
    // Arrange
    when(() => mockRepository.updateRoom(
          roomId: any(named: 'roomId'),
          name: any(named: 'name'),
          capacity: any(named: 'capacity'),
          roomType: any(named: 'roomType'),
          seatMapId: any(named: 'seatMapId'),
          isActive: any(named: 'isActive'),
        )).thenAnswer((_) async => Right(tRoom));

    // Act
    await useCase.call(tParams);

    // Assert
    verify(() => mockRepository.updateRoom(
          roomId: tRoomId,
          name: 'Updated Room',
          capacity: 150,
          roomType: RoomType.threeD,
          seatMapId: 'seat-map-2',
          isActive: true,
        )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should call repository.updateRoom with only roomId and name', () async {
    // Arrange
    final paramsNameOnly = UpdateRoomParams(
      roomId: tRoomId,
      name: 'Updated Room',
    );

    when(() => mockRepository.updateRoom(
          roomId: any(named: 'roomId'),
          name: any(named: 'name'),
        )).thenAnswer((_) async => Right(tRoom));

    // Act
    await useCase.call(paramsNameOnly);

    // Assert
    verify(() => mockRepository.updateRoom(
          roomId: tRoomId,
          name: 'Updated Room',
        )).called(1);
  });

  test('should call repository.updateRoom with only roomId and capacity', () async {
    // Arrange
    final paramsCapacityOnly = UpdateRoomParams(
      roomId: tRoomId,
      capacity: 150,
    );

    when(() => mockRepository.updateRoom(
          roomId: any(named: 'roomId'),
          capacity: any(named: 'capacity'),
        )).thenAnswer((_) async => Right(tRoom));

    // Act
    await useCase.call(paramsCapacityOnly);

    // Assert
    verify(() => mockRepository.updateRoom(
          roomId: tRoomId,
          capacity: 150,
        )).called(1);
  });

  test('should call repository.updateRoom with only roomId and isActive', () async {
    // Arrange
    final paramsIsActiveOnly = UpdateRoomParams(
      roomId: tRoomId,
      isActive: false,
    );

    when(() => mockRepository.updateRoom(
          roomId: any(named: 'roomId'),
          isActive: any(named: 'isActive'),
        )).thenAnswer((_) async => Right(tRoom));

    // Act
    await useCase.call(paramsIsActiveOnly);

    // Assert
    verify(() => mockRepository.updateRoom(
          roomId: tRoomId,
          isActive: false,
        )).called(1);
  });

  test('should return Room when update is successful', () async {
    // Arrange
    when(() => mockRepository.updateRoom(
          roomId: any(named: 'roomId'),
          name: any(named: 'name'),
          capacity: any(named: 'capacity'),
          roomType: any(named: 'roomType'),
          seatMapId: any(named: 'seatMapId'),
          isActive: any(named: 'isActive'),
        )).thenAnswer((_) async => Right(tRoom));

    // Act
    final result = await useCase.call(tParams);

    // Assert
    expect(result, Right(tRoom));
  });

  test('should return Failure when update fails', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Failed to update room');
    when(() => mockRepository.updateRoom(
          roomId: any(named: 'roomId'),
          name: any(named: 'name'),
          capacity: any(named: 'capacity'),
          roomType: any(named: 'roomType'),
          seatMapId: any(named: 'seatMapId'),
          isActive: any(named: 'isActive'),
        )).thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(tParams);

    // Assert
    expect(result, const Left(tFailure));
  });

  test('should return Failure when room not found', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Room not found', statusCode: 404);
    when(() => mockRepository.updateRoom(
          roomId: any(named: 'roomId'),
          name: any(named: 'name'),
          capacity: any(named: 'capacity'),
          roomType: any(named: 'roomType'),
          seatMapId: any(named: 'seatMapId'),
          isActive: any(named: 'isActive'),
        )).thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(tParams);

    // Assert
    expect(result, const Left(tFailure));
  });
}
