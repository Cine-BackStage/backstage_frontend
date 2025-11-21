import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/rooms/domain/entities/room.dart';
import 'package:backstage_frontend/features/rooms/domain/usecases/room_usecases.dart';
import 'package:backstage_frontend/features/rooms/presentation/bloc/room_management_bloc.dart';
import 'package:backstage_frontend/features/rooms/presentation/bloc/room_management_event.dart';
import 'package:backstage_frontend/features/rooms/presentation/bloc/room_management_state.dart';

class MockGetRoomsUseCase extends Mock implements GetRoomsUseCase {}
class MockCreateRoomUseCase extends Mock implements CreateRoomUseCase {}
class MockUpdateRoomUseCase extends Mock implements UpdateRoomUseCase {}
class MockDeleteRoomUseCase extends Mock implements DeleteRoomUseCase {}
class MockActivateRoomUseCase extends Mock implements ActivateRoomUseCase {}

void main() {
  late RoomManagementBloc bloc;
  late MockGetRoomsUseCase mockGetRoomsUseCase;
  late MockCreateRoomUseCase mockCreateRoomUseCase;
  late MockUpdateRoomUseCase mockUpdateRoomUseCase;
  late MockDeleteRoomUseCase mockDeleteRoomUseCase;
  late MockActivateRoomUseCase mockActivateRoomUseCase;

  setUpAll(() {
    registerFallbackValue(CreateRoomParams(
      name: '',
      capacity: 0,
      roomType: RoomType.twoD,
    ));
    registerFallbackValue(UpdateRoomParams(roomId: ''));
  });

  setUp(() {
    mockGetRoomsUseCase = MockGetRoomsUseCase();
    mockCreateRoomUseCase = MockCreateRoomUseCase();
    mockUpdateRoomUseCase = MockUpdateRoomUseCase();
    mockDeleteRoomUseCase = MockDeleteRoomUseCase();
    mockActivateRoomUseCase = MockActivateRoomUseCase();
    bloc = RoomManagementBloc(
      getRoomsUseCase: mockGetRoomsUseCase,
      createRoomUseCase: mockCreateRoomUseCase,
      updateRoomUseCase: mockUpdateRoomUseCase,
      deleteRoomUseCase: mockDeleteRoomUseCase,
      activateRoomUseCase: mockActivateRoomUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  final tRooms = [
    Room(
      id: 'room-1',
      name: 'Room 1',
      capacity: 100,
      roomType: RoomType.twoD,
      isActive: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    ),
    Room(
      id: 'room-2',
      name: 'Room 2',
      capacity: 150,
      roomType: RoomType.threeD,
      isActive: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    ),
  ];

  final tRoom = Room(
    id: 'room-123',
    name: 'Test Room',
    capacity: 100,
    roomType: RoomType.twoD,
    seatMapId: 'seat-map-1',
    isActive: true,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 2),
  );

  test('initial state should be RoomManagementInitial', () {
    expect(bloc.state, equals(const RoomManagementInitial()));
  });

  group('LoadRoomsRequested', () {
    blocTest<RoomManagementBloc, RoomManagementState>(
      'should emit [RoomManagementLoading, RoomManagementLoaded] when loading rooms is successful',
      build: () {
        when(() => mockGetRoomsUseCase.call(
              isActive: any(named: 'isActive'),
              roomType: any(named: 'roomType'),
            )).thenAnswer((_) async => Right(tRooms));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadRoomsRequested()),
      expect: () => [
        const RoomManagementLoading(),
        RoomManagementLoaded(rooms: tRooms),
      ],
    );

    blocTest<RoomManagementBloc, RoomManagementState>(
      'should emit [RoomManagementLoading, RoomManagementLoaded] with filtered active rooms',
      build: () {
        when(() => mockGetRoomsUseCase.call(
              isActive: any(named: 'isActive'),
              roomType: any(named: 'roomType'),
            )).thenAnswer((_) async => Right(tRooms));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadRoomsRequested(isActive: true)),
      expect: () => [
        const RoomManagementLoading(),
        RoomManagementLoaded(rooms: tRooms),
      ],
      verify: (_) {
        verify(() => mockGetRoomsUseCase.call(isActive: true)).called(1);
      },
    );

    blocTest<RoomManagementBloc, RoomManagementState>(
      'should emit [RoomManagementLoading, RoomManagementLoaded] with filtered room type',
      build: () {
        when(() => mockGetRoomsUseCase.call(
              isActive: any(named: 'isActive'),
              roomType: any(named: 'roomType'),
            )).thenAnswer((_) async => Right(tRooms));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadRoomsRequested(roomType: RoomType.twoD)),
      expect: () => [
        const RoomManagementLoading(),
        RoomManagementLoaded(rooms: tRooms),
      ],
      verify: (_) {
        verify(() => mockGetRoomsUseCase.call(roomType: RoomType.twoD)).called(1);
      },
    );

    blocTest<RoomManagementBloc, RoomManagementState>(
      'should emit [RoomManagementLoading, RoomManagementLoaded] with both filters',
      build: () {
        when(() => mockGetRoomsUseCase.call(
              isActive: any(named: 'isActive'),
              roomType: any(named: 'roomType'),
            )).thenAnswer((_) async => Right(tRooms));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadRoomsRequested(
        isActive: true,
        roomType: RoomType.threeD,
      )),
      expect: () => [
        const RoomManagementLoading(),
        RoomManagementLoaded(rooms: tRooms),
      ],
      verify: (_) {
        verify(() => mockGetRoomsUseCase.call(
              isActive: true,
              roomType: RoomType.threeD,
            )).called(1);
      },
    );

    blocTest<RoomManagementBloc, RoomManagementState>(
      'should emit [RoomManagementLoading, RoomManagementError] when loading fails',
      build: () {
        when(() => mockGetRoomsUseCase.call(
              isActive: any(named: 'isActive'),
              roomType: any(named: 'roomType'),
            )).thenAnswer((_) async => const Left(GenericFailure(message: 'Failed to load rooms')));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadRoomsRequested()),
      expect: () => [
        const RoomManagementLoading(),
        const RoomManagementError(failure: GenericFailure(message: 'Failed to load rooms')),
      ],
    );
  });

  group('RefreshRoomsRequested', () {
    blocTest<RoomManagementBloc, RoomManagementState>(
      'should emit [RoomManagementLoaded] when refresh is successful',
      build: () {
        when(() => mockGetRoomsUseCase.call(
              isActive: any(named: 'isActive'),
              roomType: any(named: 'roomType'),
            )).thenAnswer((_) async => Right(tRooms));
        return bloc;
      },
      act: (bloc) => bloc.add(const RefreshRoomsRequested()),
      expect: () => [
        RoomManagementLoaded(rooms: tRooms),
      ],
    );

    blocTest<RoomManagementBloc, RoomManagementState>(
      'should emit [RoomManagementError] when refresh fails',
      build: () {
        when(() => mockGetRoomsUseCase.call(
              isActive: any(named: 'isActive'),
              roomType: any(named: 'roomType'),
            )).thenAnswer((_) async => const Left(GenericFailure(message: 'Refresh failed')));
        return bloc;
      },
      act: (bloc) => bloc.add(const RefreshRoomsRequested()),
      expect: () => [
        const RoomManagementError(failure: GenericFailure(message: 'Refresh failed')),
      ],
    );
  });

  group('CreateRoomRequested', () {
    final tParams = CreateRoomParams(
      name: 'New Room',
      capacity: 120,
      roomType: RoomType.twoD,
      seatMapId: 'seat-map-1',
    );

    blocTest<RoomManagementBloc, RoomManagementState>(
      'should emit [RoomManagementSaving, RoomManagementSaved] when creation is successful',
      build: () {
        when(() => mockCreateRoomUseCase.call(any()))
            .thenAnswer((_) async => Right(tRoom));
        return bloc;
      },
      act: (bloc) => bloc.add(CreateRoomRequested(params: tParams)),
      expect: () => [
        const RoomManagementSaving(),
        RoomManagementSaved(room: tRoom),
      ],
    );

    blocTest<RoomManagementBloc, RoomManagementState>(
      'should call createRoomUseCase with correct params',
      build: () {
        when(() => mockCreateRoomUseCase.call(any()))
            .thenAnswer((_) async => Right(tRoom));
        return bloc;
      },
      act: (bloc) => bloc.add(CreateRoomRequested(params: tParams)),
      verify: (_) {
        verify(() => mockCreateRoomUseCase.call(tParams)).called(1);
      },
    );

    blocTest<RoomManagementBloc, RoomManagementState>(
      'should emit [RoomManagementSaving, RoomManagementError] when creation fails',
      build: () {
        when(() => mockCreateRoomUseCase.call(any()))
            .thenAnswer((_) async => const Left(GenericFailure(message: 'Failed to create room')));
        return bloc;
      },
      act: (bloc) => bloc.add(CreateRoomRequested(params: tParams)),
      expect: () => [
        const RoomManagementSaving(),
        const RoomManagementError(failure: GenericFailure(message: 'Failed to create room')),
      ],
    );
  });

  group('UpdateRoomRequested', () {
    final tParams = UpdateRoomParams(
      roomId: 'room-123',
      name: 'Updated Room',
      capacity: 150,
    );

    blocTest<RoomManagementBloc, RoomManagementState>(
      'should emit [RoomManagementSaving, RoomManagementSaved] when update is successful',
      build: () {
        when(() => mockUpdateRoomUseCase.call(any()))
            .thenAnswer((_) async => Right(tRoom));
        return bloc;
      },
      act: (bloc) => bloc.add(UpdateRoomRequested(params: tParams)),
      expect: () => [
        const RoomManagementSaving(),
        RoomManagementSaved(room: tRoom),
      ],
    );

    blocTest<RoomManagementBloc, RoomManagementState>(
      'should call updateRoomUseCase with correct params',
      build: () {
        when(() => mockUpdateRoomUseCase.call(any()))
            .thenAnswer((_) async => Right(tRoom));
        return bloc;
      },
      act: (bloc) => bloc.add(UpdateRoomRequested(params: tParams)),
      verify: (_) {
        verify(() => mockUpdateRoomUseCase.call(tParams)).called(1);
      },
    );

    blocTest<RoomManagementBloc, RoomManagementState>(
      'should emit [RoomManagementSaving, RoomManagementError] when update fails',
      build: () {
        when(() => mockUpdateRoomUseCase.call(any()))
            .thenAnswer((_) async => const Left(GenericFailure(message: 'Failed to update room')));
        return bloc;
      },
      act: (bloc) => bloc.add(UpdateRoomRequested(params: tParams)),
      expect: () => [
        const RoomManagementSaving(),
        const RoomManagementError(failure: GenericFailure(message: 'Failed to update room')),
      ],
    );
  });

  group('DeleteRoomRequested', () {
    const tRoomId = 'room-123';

    blocTest<RoomManagementBloc, RoomManagementState>(
      'should emit [RoomManagementDeleting, RoomManagementDeleted] when soft delete is successful',
      build: () {
        when(() => mockDeleteRoomUseCase.call(any(), permanent: any(named: 'permanent')))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(const DeleteRoomRequested(roomId: tRoomId)),
      expect: () => [
        const RoomManagementDeleting(),
        const RoomManagementDeleted(roomId: tRoomId),
      ],
    );

    blocTest<RoomManagementBloc, RoomManagementState>(
      'should emit [RoomManagementDeleting, RoomManagementDeleted] when permanent delete is successful',
      build: () {
        when(() => mockDeleteRoomUseCase.call(any(), permanent: any(named: 'permanent')))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(const DeleteRoomRequested(roomId: tRoomId, permanent: true)),
      expect: () => [
        const RoomManagementDeleting(),
        const RoomManagementDeleted(roomId: tRoomId),
      ],
      verify: (_) {
        verify(() => mockDeleteRoomUseCase.call(tRoomId, permanent: true)).called(1);
      },
    );

    blocTest<RoomManagementBloc, RoomManagementState>(
      'should call deleteRoomUseCase with permanent=false by default',
      build: () {
        when(() => mockDeleteRoomUseCase.call(any(), permanent: any(named: 'permanent')))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(const DeleteRoomRequested(roomId: tRoomId)),
      verify: (_) {
        verify(() => mockDeleteRoomUseCase.call(tRoomId, permanent: false)).called(1);
      },
    );

    blocTest<RoomManagementBloc, RoomManagementState>(
      'should emit [RoomManagementDeleting, RoomManagementError] when delete fails',
      build: () {
        when(() => mockDeleteRoomUseCase.call(any(), permanent: any(named: 'permanent')))
            .thenAnswer((_) async => const Left(GenericFailure(message: 'Failed to delete room')));
        return bloc;
      },
      act: (bloc) => bloc.add(const DeleteRoomRequested(roomId: tRoomId)),
      expect: () => [
        const RoomManagementDeleting(),
        const RoomManagementError(failure: GenericFailure(message: 'Failed to delete room')),
      ],
    );
  });

  group('ActivateRoomRequested', () {
    const tRoomId = 'room-123';

    blocTest<RoomManagementBloc, RoomManagementState>(
      'should emit [RoomManagementSaving, RoomManagementSaved] when activation is successful',
      build: () {
        when(() => mockActivateRoomUseCase.call(any()))
            .thenAnswer((_) async => Right(tRoom));
        return bloc;
      },
      act: (bloc) => bloc.add(const ActivateRoomRequested(roomId: tRoomId)),
      expect: () => [
        const RoomManagementSaving(),
        RoomManagementSaved(room: tRoom),
      ],
    );

    blocTest<RoomManagementBloc, RoomManagementState>(
      'should call activateRoomUseCase with correct roomId',
      build: () {
        when(() => mockActivateRoomUseCase.call(any()))
            .thenAnswer((_) async => Right(tRoom));
        return bloc;
      },
      act: (bloc) => bloc.add(const ActivateRoomRequested(roomId: tRoomId)),
      verify: (_) {
        verify(() => mockActivateRoomUseCase.call(tRoomId)).called(1);
      },
    );

    blocTest<RoomManagementBloc, RoomManagementState>(
      'should emit [RoomManagementSaving, RoomManagementError] when activation fails',
      build: () {
        when(() => mockActivateRoomUseCase.call(any()))
            .thenAnswer((_) async => const Left(GenericFailure(message: 'Failed to activate room')));
        return bloc;
      },
      act: (bloc) => bloc.add(const ActivateRoomRequested(roomId: tRoomId)),
      expect: () => [
        const RoomManagementSaving(),
        const RoomManagementError(failure: GenericFailure(message: 'Failed to activate room')),
      ],
    );
  });
}
