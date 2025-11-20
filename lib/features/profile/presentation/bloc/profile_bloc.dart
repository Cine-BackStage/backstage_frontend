import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_employee_profile_usecase.dart';
import '../../domain/usecases/change_password_usecase.dart';
import '../../domain/usecases/get_settings_usecase.dart';
import '../../domain/usecases/update_settings_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetEmployeeProfileUseCase getEmployeeProfileUseCase;
  final ChangePasswordUseCase changePasswordUseCase;
  final GetSettingsUseCase getSettingsUseCase;
  final UpdateSettingsUseCase updateSettingsUseCase;

  ProfileBloc({
    required this.getEmployeeProfileUseCase,
    required this.changePasswordUseCase,
    required this.getSettingsUseCase,
    required this.updateSettingsUseCase,
  }) : super(const ProfileInitial()) {
    on<LoadProfileRequested>(_onLoadProfileRequested);
    on<ChangePasswordRequested>(_onChangePasswordRequested);
    on<UpdateSettingsRequested>(_onUpdateSettingsRequested);
  }

  Future<void> _onLoadProfileRequested(
    LoadProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    final employeeResult = await getEmployeeProfileUseCase(NoParams());
    final settingsResult = await getSettingsUseCase(NoParams());

    await employeeResult.fold(
      (failure) async {
        emit(ProfileError(message: failure.message));
      },
      (employee) async {
        await settingsResult.fold(
          (failure) async {
            emit(ProfileError(message: failure.message));
          },
          (settings) async {
            emit(ProfileLoaded(employee: employee, settings: settings));
          },
        );
      },
    );
  }

  Future<void> _onChangePasswordRequested(
    ChangePasswordRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileUpdatingPassword());

    final result = await changePasswordUseCase(
      ChangePasswordParams(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
      ),
    );

    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (_) => emit(const ProfilePasswordUpdated()),
    );

    // Reload profile after password change
    add(const LoadProfileRequested());
  }

  Future<void> _onUpdateSettingsRequested(
    UpdateSettingsRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final result = await updateSettingsUseCase(
      UpdateSettingsParams(settings: event.settings),
    );

    await result.fold(
      (failure) async {
        emit(ProfileError(message: failure.message));
      },
      (_) async {
        // Reload profile to show updated settings
        add(const LoadProfileRequested());
      },
    );
  }
}
