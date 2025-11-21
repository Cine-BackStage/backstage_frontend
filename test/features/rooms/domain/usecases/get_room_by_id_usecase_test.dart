import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/rooms/domain/entities/room.dart';
import 'package:backstage_frontend/features/rooms/domain/repositories/rooms_repository.dart';
import 'package:backstage_frontend/features/rooms/domain/usecases/room_usecases.dart';

class MockRoomsRepository extends Mock implements RoomsRepository {}

void main() {
  late GetRoomByIdUseCaseImpl useCase;
  late MockRoomsRepository mockRepository;

  setUp(() {
    mockRepository = MockRoomsRepository();
    useCase = GetRoomByIdUseCaseImpl(mockRepository);
  });

  const tRoomId = 'room-123';
  final tRoom = Room(
    id: tRoomId,
    name: 'Test Room',
    capacity: 100,
    roomType: RoomType.twoD,
    seatMapId: 'seat-map-1',
    isActive: true,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
    sessionsCount: 5,
  );

  test('should call repository.getRoomById with correct roomId', () async {
    // Arrange
    when(() => mockRepository.getRoomById(any()))
        .thenAnswer((_) async => Right(tRoom));

    // Act
    await useCase.call(tRoomId);

    // Assert
    verify(() => mockRepository.getRoomById(tRoomId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return Room when call is successful', () async {
    // Arrange
    when(() => mockRepository.getRoomById(any()))
        .thenAnswer((_) async => Right(tRoom));

    // Act
    final result = await useCase.call(tRoomId);

    // Assert
    expect(result, Right(tRoom));
  });

  test('should return Failure when room is not found', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Room not found', statusCode: 404);
    when(() => mockRepository.getRoomById(any()))
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(tRoomId);

    // Assert
    expect(result, const Left(tFailure));
  });

  test('should return Failure when call fails', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Failed to fetch room');
    when(() => mockRepository.getRoomById(any()))
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(tRoomId);

    // Assert
    expect(result, const Left(tFailure));
  });
}
