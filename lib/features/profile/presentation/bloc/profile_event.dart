import 'package:equatable/equatable.dart';
import '../../domain/entities/settings.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfileRequested extends ProfileEvent {
  const LoadProfileRequested();
}

class ChangePasswordRequested extends ProfileEvent {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordRequested({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

class UpdateSettingsRequested extends ProfileEvent {
  final Settings settings;

  const UpdateSettingsRequested({required this.settings});

  @override
  List<Object?> get props => [settings];
}
