import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/room.dart';

abstract class RoomManagementState extends Equatable {
  const RoomManagementState();

  @override
  List<Object?> get props => [];

  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(List<Room> rooms) loaded,
    required T Function() saving,
    required T Function(Room room) saved,
    required T Function() deleting,
    required T Function(String roomId) deleted,
    required T Function(Failure failure) error,
  }) {
    if (this is RoomManagementInitial) return initial();
    if (this is RoomManagementLoading) return loading();
    if (this is RoomManagementLoaded) return loaded((this as RoomManagementLoaded).rooms);
    if (this is RoomManagementSaving) return saving();
    if (this is RoomManagementSaved) return saved((this as RoomManagementSaved).room);
    if (this is RoomManagementDeleting) return deleting();
    if (this is RoomManagementDeleted) return deleted((this as RoomManagementDeleted).roomId);
    if (this is RoomManagementError) return error((this as RoomManagementError).failure);
    throw Exception('Invalid state: $runtimeType');
  }

  T? whenOrNull<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(List<Room> rooms)? loaded,
    T Function()? saving,
    T Function(Room room)? saved,
    T Function()? deleting,
    T Function(String roomId)? deleted,
    T Function(Failure failure)? error,
  }) {
    if (this is RoomManagementInitial && initial != null) return initial();
    if (this is RoomManagementLoading && loading != null) return loading();
    if (this is RoomManagementLoaded && loaded != null) return loaded((this as RoomManagementLoaded).rooms);
    if (this is RoomManagementSaving && saving != null) return saving();
    if (this is RoomManagementSaved && saved != null) return saved((this as RoomManagementSaved).room);
    if (this is RoomManagementDeleting && deleting != null) return deleting();
    if (this is RoomManagementDeleted && deleted != null) return deleted((this as RoomManagementDeleted).roomId);
    if (this is RoomManagementError && error != null) return error((this as RoomManagementError).failure);
    return null;
  }
}

class RoomManagementInitial extends RoomManagementState {
  const RoomManagementInitial();
}

class RoomManagementLoading extends RoomManagementState {
  const RoomManagementLoading();
}

class RoomManagementLoaded extends RoomManagementState {
  final List<Room> rooms;
  const RoomManagementLoaded({required this.rooms});
  @override
  List<Object?> get props => [rooms];
}

class RoomManagementSaving extends RoomManagementState {
  const RoomManagementSaving();
}

class RoomManagementSaved extends RoomManagementState {
  final Room room;
  const RoomManagementSaved({required this.room});
  @override
  List<Object?> get props => [room];
}

class RoomManagementDeleting extends RoomManagementState {
  const RoomManagementDeleting();
}

class RoomManagementDeleted extends RoomManagementState {
  final String roomId;
  const RoomManagementDeleted({required this.roomId});
  @override
  List<Object?> get props => [roomId];
}

class RoomManagementError extends RoomManagementState {
  final Failure failure;
  const RoomManagementError({required this.failure});
  @override
  List<Object?> get props => [failure];
  String get message => failure.userMessage;
}
