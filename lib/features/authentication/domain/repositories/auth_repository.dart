import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../entities/credentials.dart';
import '../entities/feature_info.dart';
import '../errors/auth_exceptions.dart';

/// Authentication repository contract
abstract class AuthRepository {
  /// Login with credentials
  Future<Either<AuthException, User>> login(Credentials credentials);

  /// Logout current user
  Future<Either<AuthException, void>> logout();

  /// Check if user is authenticated
  Future<Either<AuthException, User?>> checkAuthStatus();

  /// Get current authenticated user
  Future<Either<AuthException, User?>> getCurrentUser();

  /// Request password reset
  /// TODO: Implement email/SMS integration for password reset
  Future<Either<AuthException, void>> requestPasswordReset(String cpf);

  /// Get feature info for carousel
  Future<Either<AuthException, List<FeatureInfo>>> getFeatures();
}
