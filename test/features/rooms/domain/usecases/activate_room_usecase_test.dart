import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/rooms/domain/entities/room.dart';
import 'package:backstage_frontend/features/rooms/domain/repositories/rooms_repository.dart';
import 'package:backstage_frontend/features/rooms/domain/usecases/room_usecases.dart';

class MockRoomsRepository extends Mock implements RoomsRepository {}

void main() {
  late ActivateRoomUseCaseImpl useCase;
  late MockRoomsRepository mockRepository;

  setUp(() {
    mockRepository = MockRoomsRepository();
    useCase = ActivateRoomUseCaseImpl(mockRepository);
  });

  const tRoomId = 'room-123';
  final tRoom = Room(
    id: tRoomId,
    name: 'Test Room',
    capacity: 100,
    roomType: RoomType.twoD,
    isActive: true,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 2),
  );

  test('should call repository.activateRoom with correct roomId', () async {
    // Arrange
    when(() => mockRepository.activateRoom(any()))
        .thenAnswer((_) async => Right(tRoom));

    // Act
    await useCase.call(tRoomId);

    // Assert
    verify(() => mockRepository.activateRoom(tRoomId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return activated Room when activation is successful', () async {
    // Arrange
    when(() => mockRepository.activateRoom(any()))
        .thenAnswer((_) async => Right(tRoom));

    // Act
    final result = await useCase.call(tRoomId);

    // Assert
    expect(result, Right(tRoom));
    result.fold(
      (failure) => fail('Expected Right but got Left'),
      (room) {
        expect(room.isActive, true);
        expect(room.id, tRoomId);
      },
    );
  });

  test('should return Failure when activation fails', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Failed to activate room');
    when(() => mockRepository.activateRoom(any()))
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(tRoomId);

    // Assert
    expect(result, const Left(tFailure));
  });

  test('should return Failure when room not found', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Room not found', statusCode: 404);
    when(() => mockRepository.activateRoom(any()))
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(tRoomId);

    // Assert
    expect(result, const Left(tFailure));
  });

  test('should return Failure when room is already active', () async {
    // Arrange
    const tFailure = GenericFailure(
      message: 'Room is already active',
      statusCode: 409,
    );
    when(() => mockRepository.activateRoom(any()))
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(tRoomId);

    // Assert
    expect(result, const Left(tFailure));
  });
}
