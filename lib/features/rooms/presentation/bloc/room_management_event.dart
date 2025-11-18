import 'package:equatable/equatable.dart';
import '../../domain/entities/room.dart';
import '../../domain/usecases/room_usecases.dart';

abstract class RoomManagementEvent extends Equatable {
  const RoomManagementEvent();

  @override
  List<Object?> get props => [];
}

class LoadRoomsRequested extends RoomManagementEvent {
  final bool? isActive;
  final RoomType? roomType;

  const LoadRoomsRequested({this.isActive, this.roomType});

  @override
  List<Object?> get props => [isActive, roomType];
}

class RefreshRoomsRequested extends RoomManagementEvent {
  const RefreshRoomsRequested();
}

class CreateRoomRequested extends RoomManagementEvent {
  final CreateRoomParams params;

  const CreateRoomRequested({required this.params});

  @override
  List<Object?> get props => [params];
}

class UpdateRoomRequested extends RoomManagementEvent {
  final UpdateRoomParams params;

  const UpdateRoomRequested({required this.params});

  @override
  List<Object?> get props => [params];
}

class DeleteRoomRequested extends RoomManagementEvent {
  final String roomId;
  final bool permanent;

  const DeleteRoomRequested({
    required this.roomId,
    this.permanent = false,
  });

  @override
  List<Object?> get props => [roomId, permanent];
}

class ActivateRoomRequested extends RoomManagementEvent {
  final String roomId;

  const ActivateRoomRequested({required this.roomId});

  @override
  List<Object?> get props => [roomId];
}
