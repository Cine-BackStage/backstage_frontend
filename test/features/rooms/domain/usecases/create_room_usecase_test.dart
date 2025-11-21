import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/rooms/domain/entities/room.dart';
import 'package:backstage_frontend/features/rooms/domain/repositories/rooms_repository.dart';
import 'package:backstage_frontend/features/rooms/domain/usecases/room_usecases.dart';

class MockRoomsRepository extends Mock implements RoomsRepository {}

void main() {
  late CreateRoomUseCaseImpl useCase;
  late MockRoomsRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(RoomType.twoD);
  });

  setUp(() {
    mockRepository = MockRoomsRepository();
    useCase = CreateRoomUseCaseImpl(mockRepository);
  });

  final tParams = CreateRoomParams(
    name: 'New Room',
    capacity: 120,
    roomType: RoomType.twoD,
    seatMapId: 'seat-map-1',
  );

  final tRoom = Room(
    id: 'room-123',
    name: 'New Room',
    capacity: 120,
    roomType: RoomType.twoD,
    seatMapId: 'seat-map-1',
    isActive: true,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  test('should call repository.createRoom with correct parameters', () async {
    // Arrange
    when(() => mockRepository.createRoom(
          name: any(named: 'name'),
          capacity: any(named: 'capacity'),
          roomType: any(named: 'roomType'),
          seatMapId: any(named: 'seatMapId'),
        )).thenAnswer((_) async => Right(tRoom));

    // Act
    await useCase.call(tParams);

    // Assert
    verify(() => mockRepository.createRoom(
          name: 'New Room',
          capacity: 120,
          roomType: RoomType.twoD,
          seatMapId: 'seat-map-1',
        )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should call repository.createRoom without seatMapId when not provided', () async {
    // Arrange
    final paramsWithoutSeatMap = CreateRoomParams(
      name: 'New Room',
      capacity: 120,
      roomType: RoomType.twoD,
    );

    when(() => mockRepository.createRoom(
          name: any(named: 'name'),
          capacity: any(named: 'capacity'),
          roomType: any(named: 'roomType'),
        )).thenAnswer((_) async => Right(tRoom));

    // Act
    await useCase.call(paramsWithoutSeatMap);

    // Assert
    verify(() => mockRepository.createRoom(
          name: 'New Room',
          capacity: 120,
          roomType: RoomType.twoD,
        )).called(1);
  });

  test('should return Room when creation is successful', () async {
    // Arrange
    when(() => mockRepository.createRoom(
          name: any(named: 'name'),
          capacity: any(named: 'capacity'),
          roomType: any(named: 'roomType'),
          seatMapId: any(named: 'seatMapId'),
        )).thenAnswer((_) async => Right(tRoom));

    // Act
    final result = await useCase.call(tParams);

    // Assert
    expect(result, Right(tRoom));
  });

  test('should return Failure when creation fails', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Failed to create room');
    when(() => mockRepository.createRoom(
          name: any(named: 'name'),
          capacity: any(named: 'capacity'),
          roomType: any(named: 'roomType'),
          seatMapId: any(named: 'seatMapId'),
        )).thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(tParams);

    // Assert
    expect(result, const Left(tFailure));
  });

  test('should return Failure when validation fails', () async {
    // Arrange
    const tFailure = GenericFailure(
      message: 'Room name already exists',
      statusCode: 409,
    );
    when(() => mockRepository.createRoom(
          name: any(named: 'name'),
          capacity: any(named: 'capacity'),
          roomType: any(named: 'roomType'),
          seatMapId: any(named: 'seatMapId'),
        )).thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(tParams);

    // Assert
    expect(result, const Left(tFailure));
  });
}
