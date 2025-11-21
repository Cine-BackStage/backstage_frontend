import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/rooms/domain/entities/room.dart';
import 'package:backstage_frontend/features/rooms/domain/repositories/rooms_repository.dart';
import 'package:backstage_frontend/features/rooms/domain/usecases/room_usecases.dart';

class MockRoomsRepository extends Mock implements RoomsRepository {}

void main() {
  late GetRoomsUseCaseImpl useCase;
  late MockRoomsRepository mockRepository;

  setUp(() {
    mockRepository = MockRoomsRepository();
    useCase = GetRoomsUseCaseImpl(mockRepository);
  });

  final tRooms = [
    Room(
      id: '1',
      name: 'Room 1',
      capacity: 100,
      roomType: RoomType.twoD,
      isActive: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    ),
    Room(
      id: '2',
      name: 'Room 2',
      capacity: 150,
      roomType: RoomType.threeD,
      isActive: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    ),
  ];

  test('should call repository.getRooms with no filters', () async {
    // Arrange
    when(() => mockRepository.getRooms())
        .thenAnswer((_) async => Right(tRooms));

    // Act
    await useCase.call();

    // Assert
    verify(() => mockRepository.getRooms()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should call repository.getRooms with isActive filter', () async {
    // Arrange
    when(() => mockRepository.getRooms(isActive: any(named: 'isActive')))
        .thenAnswer((_) async => Right(tRooms));

    // Act
    await useCase.call(isActive: true);

    // Assert
    verify(() => mockRepository.getRooms(isActive: true)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should call repository.getRooms with roomType filter', () async {
    // Arrange
    when(() => mockRepository.getRooms(roomType: any(named: 'roomType')))
        .thenAnswer((_) async => Right(tRooms));

    // Act
    await useCase.call(roomType: RoomType.twoD);

    // Assert
    verify(() => mockRepository.getRooms(roomType: RoomType.twoD)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should call repository.getRooms with both filters', () async {
    // Arrange
    when(() => mockRepository.getRooms(
          isActive: any(named: 'isActive'),
          roomType: any(named: 'roomType'),
        )).thenAnswer((_) async => Right(tRooms));

    // Act
    await useCase.call(isActive: true, roomType: RoomType.twoD);

    // Assert
    verify(() => mockRepository.getRooms(
          isActive: true,
          roomType: RoomType.twoD,
        )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return list of rooms when call is successful', () async {
    // Arrange
    when(() => mockRepository.getRooms())
        .thenAnswer((_) async => Right(tRooms));

    // Act
    final result = await useCase.call();

    // Assert
    expect(result, Right(tRooms));
  });

  test('should return Failure when call fails', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Failed to fetch rooms');
    when(() => mockRepository.getRooms())
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call();

    // Assert
    expect(result, const Left(tFailure));
  });
}
