import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/employee.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/login_request.dart';

/// Authentication repository implementation
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, Employee>> login(
    String employeeId,
    String password,
  ) async {
    try {
      // Call remote API
      final loginRequest = LoginRequest(
        employeeId: employeeId,
        password: password,
      );

      final loginResponse = await remoteDataSource.login(loginRequest);

      // Cache token and employee data
      await localDataSource.cacheToken(loginResponse.token);
      await localDataSource.cacheEmployee(loginResponse.employee);

      return Right(loginResponse.employee);
    } on AppException catch (e) {
      return Left(GenericFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(GenericFailure(
        message: 'Erro inesperado: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearAuthData();
      return const Right(null);
    } catch (e) {
      return Left(GenericFailure(
        message: 'Erro ao fazer logout: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final token = await localDataSource.getCachedToken();
      return Right(token != null && token.isNotEmpty);
    } catch (e) {
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, Employee>> getCurrentEmployee() async {
    try {
      final employee = await localDataSource.getCachedEmployee();
      return Right(employee);
    } on AppException catch (e) {
      return Left(GenericFailure(message: e.message));
    } catch (e) {
      return Left(GenericFailure(
        message: 'Erro ao buscar usuário: ${e.toString()}',
      ));
    }
  }
}
