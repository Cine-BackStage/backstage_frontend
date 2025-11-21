import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/rooms/domain/repositories/rooms_repository.dart';
import 'package:backstage_frontend/features/rooms/domain/usecases/room_usecases.dart';

class MockRoomsRepository extends Mock implements RoomsRepository {}

void main() {
  late DeleteRoomUseCaseImpl useCase;
  late MockRoomsRepository mockRepository;

  setUp(() {
    mockRepository = MockRoomsRepository();
    useCase = DeleteRoomUseCaseImpl(mockRepository);
  });

  const tRoomId = 'room-123';

  test('should call repository.deleteRoom with soft delete by default', () async {
    // Arrange
    when(() => mockRepository.deleteRoom(any(), permanent: any(named: 'permanent')))
        .thenAnswer((_) async => const Right(null));

    // Act
    await useCase.call(tRoomId);

    // Assert
    verify(() => mockRepository.deleteRoom(tRoomId, permanent: false)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should call repository.deleteRoom with permanent delete when specified', () async {
    // Arrange
    when(() => mockRepository.deleteRoom(any(), permanent: any(named: 'permanent')))
        .thenAnswer((_) async => const Right(null));

    // Act
    await useCase.call(tRoomId, permanent: true);

    // Assert
    verify(() => mockRepository.deleteRoom(tRoomId, permanent: true)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return Right(null) when soft delete is successful', () async {
    // Arrange
    when(() => mockRepository.deleteRoom(any(), permanent: any(named: 'permanent')))
        .thenAnswer((_) async => const Right(null));

    // Act
    final result = await useCase.call(tRoomId);

    // Assert
    expect(result, const Right(null));
  });

  test('should return Right(null) when permanent delete is successful', () async {
    // Arrange
    when(() => mockRepository.deleteRoom(any(), permanent: any(named: 'permanent')))
        .thenAnswer((_) async => const Right(null));

    // Act
    final result = await useCase.call(tRoomId, permanent: true);

    // Assert
    expect(result, const Right(null));
  });

  test('should return Failure when delete fails', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Failed to delete room');
    when(() => mockRepository.deleteRoom(any(), permanent: any(named: 'permanent')))
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(tRoomId);

    // Assert
    expect(result, const Left(tFailure));
  });

  test('should return Failure when room not found', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Room not found', statusCode: 404);
    when(() => mockRepository.deleteRoom(any(), permanent: any(named: 'permanent')))
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(tRoomId);

    // Assert
    expect(result, const Left(tFailure));
  });

  test('should return Failure when room has active sessions', () async {
    // Arrange
    const tFailure = GenericFailure(
      message: 'Cannot delete room with active sessions',
      statusCode: 409,
    );
    when(() => mockRepository.deleteRoom(any(), permanent: any(named: 'permanent')))
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(tRoomId);

    // Assert
    expect(result, const Left(tFailure));
  });
}
