import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/core/usecases/usecase.dart';
import 'package:backstage_frontend/features/authentication/domain/entities/employee.dart';
import 'package:backstage_frontend/features/profile/domain/entities/settings.dart';
import 'package:backstage_frontend/features/profile/domain/usecases/change_password_usecase.dart';
import 'package:backstage_frontend/features/profile/domain/usecases/get_employee_profile_usecase.dart';
import 'package:backstage_frontend/features/profile/domain/usecases/get_settings_usecase.dart';
import 'package:backstage_frontend/features/profile/domain/usecases/update_settings_usecase.dart';
import 'package:backstage_frontend/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:backstage_frontend/features/profile/presentation/bloc/profile_event.dart';
import 'package:backstage_frontend/features/profile/presentation/bloc/profile_state.dart';

class MockGetEmployeeProfileUseCase extends Mock implements GetEmployeeProfileUseCase {}
class MockChangePasswordUseCase extends Mock implements ChangePasswordUseCase {}
class MockGetSettingsUseCase extends Mock implements GetSettingsUseCase {}
class MockUpdateSettingsUseCase extends Mock implements UpdateSettingsUseCase {}

void main() {
  late ProfileBloc profileBloc;
  late MockGetEmployeeProfileUseCase mockGetEmployeeProfileUseCase;
  late MockChangePasswordUseCase mockChangePasswordUseCase;
  late MockGetSettingsUseCase mockGetSettingsUseCase;
  late MockUpdateSettingsUseCase mockUpdateSettingsUseCase;

  setUpAll(() {
    registerFallbackValue(NoParams());
    registerFallbackValue(ChangePasswordParams(
      currentPassword: '',
      newPassword: '',
    ));
    registerFallbackValue(UpdateSettingsParams(
      settings: const Settings(
        language: 'pt_BR',
        theme: 'dark',
        notifications: true,
      ),
    ));
  });

  setUp(() {
    mockGetEmployeeProfileUseCase = MockGetEmployeeProfileUseCase();
    mockChangePasswordUseCase = MockChangePasswordUseCase();
    mockGetSettingsUseCase = MockGetSettingsUseCase();
    mockUpdateSettingsUseCase = MockUpdateSettingsUseCase();
    profileBloc = ProfileBloc(
      getEmployeeProfileUseCase: mockGetEmployeeProfileUseCase,
      changePasswordUseCase: mockChangePasswordUseCase,
      getSettingsUseCase: mockGetSettingsUseCase,
      updateSettingsUseCase: mockUpdateSettingsUseCase,
    );
  });

  tearDown(() {
    profileBloc.close();
  });

  const tEmployee = Employee(
    cpf: '123.456.789-00',
    companyId: 'comp-123',
    employeeId: '12345',
    role: 'cashier',
    fullName: 'John Doe',
    email: 'john@example.com',
    isActive: true,
  );

  const tSettings = Settings(
    language: 'pt_BR',
    theme: 'dark',
    notifications: true,
  );

  test('initial state should be ProfileInitial', () {
    expect(profileBloc.state, equals(const ProfileInitial()));
  });

  group('LoadProfileRequested', () {
    blocTest<ProfileBloc, ProfileState>(
      'should emit [ProfileLoading, ProfileLoaded] when both profile and settings are loaded successfully',
      build: () {
        when(() => mockGetEmployeeProfileUseCase.call(any()))
            .thenAnswer((_) async => const Right(tEmployee));
        when(() => mockGetSettingsUseCase.call(any()))
            .thenAnswer((_) async => const Right(tSettings));
        return profileBloc;
      },
      act: (bloc) => bloc.add(const LoadProfileRequested()),
      expect: () => [
        const ProfileLoading(),
        const ProfileLoaded(employee: tEmployee, settings: tSettings),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'should emit [ProfileLoading, ProfileError] when getting employee profile fails',
      build: () {
        when(() => mockGetEmployeeProfileUseCase.call(any()))
            .thenAnswer((_) async => const Left(GenericFailure(message: 'Failed to get profile')));
        when(() => mockGetSettingsUseCase.call(any()))
            .thenAnswer((_) async => const Right(tSettings));
        return profileBloc;
      },
      act: (bloc) => bloc.add(const LoadProfileRequested()),
      wait: const Duration(milliseconds: 500),
      expect: () => [
        const ProfileLoading(),
        const ProfileError(message: 'Failed to get profile'),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'should emit [ProfileLoading, ProfileError] when getting settings fails',
      build: () {
        when(() => mockGetEmployeeProfileUseCase.call(any()))
            .thenAnswer((_) async => const Right(tEmployee));
        when(() => mockGetSettingsUseCase.call(any()))
            .thenAnswer((_) async => const Left(GenericFailure(message: 'Failed to get settings')));
        return profileBloc;
      },
      act: (bloc) => bloc.add(const LoadProfileRequested()),
      wait: const Duration(milliseconds: 500),
      expect: () => [
        const ProfileLoading(),
        const ProfileError(message: 'Failed to get settings'),
      ],
    );
  });

  group('ChangePasswordRequested', () {
    const tCurrentPassword = 'oldPassword123';
    const tNewPassword = 'newPassword456';

    blocTest<ProfileBloc, ProfileState>(
      'should emit [ProfileUpdatingPassword, ProfilePasswordUpdated, ProfileLoading, ProfileLoaded] when password change is successful',
      build: () {
        when(() => mockChangePasswordUseCase.call(any()))
            .thenAnswer((_) async => const Right(null));
        when(() => mockGetEmployeeProfileUseCase.call(any()))
            .thenAnswer((_) async => const Right(tEmployee));
        when(() => mockGetSettingsUseCase.call(any()))
            .thenAnswer((_) async => const Right(tSettings));
        return profileBloc;
      },
      act: (bloc) => bloc.add(const ChangePasswordRequested(
        currentPassword: tCurrentPassword,
        newPassword: tNewPassword,
      )),
      expect: () => [
        const ProfileUpdatingPassword(),
        const ProfilePasswordUpdated(),
        const ProfileLoading(),
        const ProfileLoaded(employee: tEmployee, settings: tSettings),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'should emit [ProfileUpdatingPassword, ProfileError, ProfileLoading, ProfileLoaded] when password change fails',
      build: () {
        when(() => mockChangePasswordUseCase.call(any()))
            .thenAnswer((_) async => const Left(GenericFailure(message: 'Invalid current password')));
        when(() => mockGetEmployeeProfileUseCase.call(any()))
            .thenAnswer((_) async => const Right(tEmployee));
        when(() => mockGetSettingsUseCase.call(any()))
            .thenAnswer((_) async => const Right(tSettings));
        return profileBloc;
      },
      act: (bloc) => bloc.add(const ChangePasswordRequested(
        currentPassword: tCurrentPassword,
        newPassword: tNewPassword,
      )),
      expect: () => [
        const ProfileUpdatingPassword(),
        const ProfileError(message: 'Invalid current password'),
        const ProfileLoading(),
        const ProfileLoaded(employee: tEmployee, settings: tSettings),
      ],
    );
  });

  group('UpdateSettingsRequested', () {
    const tNewSettings = Settings(
      language: 'en_US',
      theme: 'light',
      notifications: false,
    );

    blocTest<ProfileBloc, ProfileState>(
      'should emit [ProfileLoading, ProfileLoaded] when settings update is successful',
      build: () {
        when(() => mockUpdateSettingsUseCase.call(any()))
            .thenAnswer((_) async => const Right(null));
        when(() => mockGetEmployeeProfileUseCase.call(any()))
            .thenAnswer((_) async => const Right(tEmployee));
        when(() => mockGetSettingsUseCase.call(any()))
            .thenAnswer((_) async => const Right(tNewSettings));
        return profileBloc;
      },
      act: (bloc) => bloc.add(const UpdateSettingsRequested(settings: tNewSettings)),
      expect: () => [
        const ProfileLoading(),
        const ProfileLoaded(employee: tEmployee, settings: tNewSettings),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'should emit [ProfileError] when settings update fails',
      build: () {
        when(() => mockUpdateSettingsUseCase.call(any()))
            .thenAnswer((_) async => const Left(GenericFailure(message: 'Failed to update settings')));
        return profileBloc;
      },
      act: (bloc) => bloc.add(const UpdateSettingsRequested(settings: tNewSettings)),
      expect: () => [
        const ProfileError(message: 'Failed to update settings'),
      ],
    );
  });
}
