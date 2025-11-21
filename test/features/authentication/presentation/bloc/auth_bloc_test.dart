import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/core/usecases/usecase.dart';
import 'package:backstage_frontend/features/authentication/domain/entities/employee.dart';
import 'package:backstage_frontend/features/authentication/domain/usecases/check_auth_status_usecase.dart';
import 'package:backstage_frontend/features/authentication/domain/usecases/get_current_employee_usecase.dart';
import 'package:backstage_frontend/features/authentication/domain/usecases/login_usecase.dart';
import 'package:backstage_frontend/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:backstage_frontend/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:backstage_frontend/features/authentication/presentation/bloc/auth_event.dart';
import 'package:backstage_frontend/features/authentication/presentation/bloc/auth_state.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}
class MockLogoutUseCase extends Mock implements LogoutUseCase {}
class MockCheckAuthStatusUseCase extends Mock implements CheckAuthStatusUseCase {}
class MockGetCurrentEmployeeUseCase extends Mock implements GetCurrentEmployeeUseCase {}

void main() {
  late AuthBloc authBloc;
  late MockLoginUseCase mockLoginUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockCheckAuthStatusUseCase mockCheckAuthStatusUseCase;
  late MockGetCurrentEmployeeUseCase mockGetCurrentEmployeeUseCase;

  setUpAll(() {
    registerFallbackValue(NoParams());
    registerFallbackValue(LoginParams(employeeId: '', password: ''));
  });

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockCheckAuthStatusUseCase = MockCheckAuthStatusUseCase();
    mockGetCurrentEmployeeUseCase = MockGetCurrentEmployeeUseCase();
    authBloc = AuthBloc(
      loginUseCase: mockLoginUseCase,
      logoutUseCase: mockLogoutUseCase,
      checkAuthStatusUseCase: mockCheckAuthStatusUseCase,
      getCurrentEmployeeUseCase: mockGetCurrentEmployeeUseCase,
    );
  });

  tearDown(() {
    authBloc.close();
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

  test('initial state should be AuthInitial', () {
    expect(authBloc.state, equals(const AuthInitial()));
  });

  group('AuthCheckRequested', () {
    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, Authenticated] when user is authenticated',
      build: () {
        when(() => mockCheckAuthStatusUseCase.call(any()))
            .thenAnswer((_) async => const Right(true));
        when(() => mockGetCurrentEmployeeUseCase.call(any()))
            .thenAnswer((_) async => const Right(tEmployee));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [
        const AuthLoading(),
        const Authenticated(tEmployee),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, Unauthenticated] when user is not authenticated',
      build: () {
        when(() => mockCheckAuthStatusUseCase.call(any()))
            .thenAnswer((_) async => const Right(false));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [
        const AuthLoading(),
        const Unauthenticated(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, Unauthenticated] when check fails',
      build: () {
        when(() => mockCheckAuthStatusUseCase.call(any()))
            .thenAnswer((_) async => const Left(GenericFailure(message: 'Check failed')));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [
        const AuthLoading(),
        const Unauthenticated(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, Unauthenticated] when getting employee fails',
      build: () {
        when(() => mockCheckAuthStatusUseCase.call(any()))
            .thenAnswer((_) async => const Right(true));
        when(() => mockGetCurrentEmployeeUseCase.call(any()))
            .thenAnswer((_) async => const Left(GenericFailure(message: 'Employee not found')));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [
        const AuthLoading(),
        const Unauthenticated(),
      ],
    );
  });

  group('LoginRequested', () {
    const tEmployeeId = '12345';
    const tPassword = 'password123';

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, Authenticated] when login is successful',
      build: () {
        when(() => mockLoginUseCase.call(any()))
            .thenAnswer((_) async => const Right(tEmployee));
        return authBloc;
      },
      act: (bloc) => bloc.add(const LoginRequested(
        employeeId: tEmployeeId,
        password: tPassword,
      )),
      expect: () => [
        const AuthLoading(),
        const Authenticated(tEmployee),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, AuthError] when login fails',
      build: () {
        when(() => mockLoginUseCase.call(any()))
            .thenAnswer((_) async => const Left(GenericFailure(message: 'Invalid credentials')));
        return authBloc;
      },
      act: (bloc) => bloc.add(const LoginRequested(
        employeeId: tEmployeeId,
        password: tPassword,
      )),
      expect: () => [
        const AuthLoading(),
        const AuthError('Invalid credentials'),
      ],
    );
  });

  group('LogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, Unauthenticated] when logout is successful',
      build: () {
        when(() => mockLogoutUseCase.call(any()))
            .thenAnswer((_) async => const Right(null));
        return authBloc;
      },
      act: (bloc) => bloc.add(const LogoutRequested()),
      expect: () => [
        const AuthLoading(),
        const Unauthenticated(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, AuthError] when logout fails',
      build: () {
        when(() => mockLogoutUseCase.call(any()))
            .thenAnswer((_) async => const Left(GenericFailure(message: 'Logout failed')));
        return authBloc;
      },
      act: (bloc) => bloc.add(const LogoutRequested()),
      expect: () => [
        const AuthLoading(),
        const AuthError('Logout failed'),
      ],
    );
  });
}
