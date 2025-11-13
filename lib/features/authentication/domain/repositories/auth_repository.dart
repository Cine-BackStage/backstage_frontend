import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/employee.dart';

/// Authentication repository interface
abstract class AuthRepository {
  /// Login with employee credentials
  Future<Either<Failure, Employee>> login(String employeeId, String password);

  /// Logout (clear stored credentials)
  Future<Either<Failure, void>> logout();

  /// Check if user is authenticated (has valid token)
  Future<Either<Failure, bool>> isAuthenticated();

  /// Get current employee from storage
  Future<Either<Failure, Employee>> getCurrentEmployee();
}
