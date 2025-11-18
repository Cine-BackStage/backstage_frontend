import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/room_usecases.dart';
import 'room_management_event.dart';
import 'room_management_state.dart';

class RoomManagementBloc extends Bloc<RoomManagementEvent, RoomManagementState> {
  final GetRoomsUseCase getRoomsUseCase;
  final CreateRoomUseCase createRoomUseCase;
  final UpdateRoomUseCase updateRoomUseCase;
  final DeleteRoomUseCase deleteRoomUseCase;
  final ActivateRoomUseCase activateRoomUseCase;

  RoomManagementBloc({
    required this.getRoomsUseCase,
    required this.createRoomUseCase,
    required this.updateRoomUseCase,
    required this.deleteRoomUseCase,
    required this.activateRoomUseCase,
  }) : super(const RoomManagementInitial()) {
    on<LoadRoomsRequested>(_onLoadRoomsRequested);
    on<RefreshRoomsRequested>(_onRefreshRoomsRequested);
    on<CreateRoomRequested>(_onCreateRoomRequested);
    on<UpdateRoomRequested>(_onUpdateRoomRequested);
    on<DeleteRoomRequested>(_onDeleteRoomRequested);
    on<ActivateRoomRequested>(_onActivateRoomRequested);
  }

  Future<void> _onLoadRoomsRequested(
    LoadRoomsRequested event,
    Emitter<RoomManagementState> emit,
  ) async {
    emit(const RoomManagementLoading());

    final result = await getRoomsUseCase(
      isActive: event.isActive,
      roomType: event.roomType,
    );

    result.fold(
      (failure) => emit(RoomManagementError(failure: failure)),
      (rooms) => emit(RoomManagementLoaded(rooms: rooms)),
    );
  }

  Future<void> _onRefreshRoomsRequested(
    RefreshRoomsRequested event,
    Emitter<RoomManagementState> emit,
  ) async {
    final result = await getRoomsUseCase();

    result.fold(
      (failure) => emit(RoomManagementError(failure: failure)),
      (rooms) => emit(RoomManagementLoaded(rooms: rooms)),
    );
  }

  Future<void> _onCreateRoomRequested(
    CreateRoomRequested event,
    Emitter<RoomManagementState> emit,
  ) async {
    emit(const RoomManagementSaving());

    final result = await createRoomUseCase(event.params);

    result.fold(
      (failure) => emit(RoomManagementError(failure: failure)),
      (room) => emit(RoomManagementSaved(room: room)),
    );
  }

  Future<void> _onUpdateRoomRequested(
    UpdateRoomRequested event,
    Emitter<RoomManagementState> emit,
  ) async {
    emit(const RoomManagementSaving());

    final result = await updateRoomUseCase(event.params);

    result.fold(
      (failure) => emit(RoomManagementError(failure: failure)),
      (room) => emit(RoomManagementSaved(room: room)),
    );
  }

  Future<void> _onDeleteRoomRequested(
    DeleteRoomRequested event,
    Emitter<RoomManagementState> emit,
  ) async {
    emit(const RoomManagementDeleting());

    final result = await deleteRoomUseCase(event.roomId, permanent: event.permanent);

    result.fold(
      (failure) => emit(RoomManagementError(failure: failure)),
      (_) => emit(RoomManagementDeleted(roomId: event.roomId)),
    );
  }

  Future<void> _onActivateRoomRequested(
    ActivateRoomRequested event,
    Emitter<RoomManagementState> emit,
  ) async {
    emit(const RoomManagementSaving());

    final result = await activateRoomUseCase(event.roomId);

    result.fold(
      (failure) => emit(RoomManagementError(failure: failure)),
      (room) => emit(RoomManagementSaved(room: room)),
    );
  }
}
