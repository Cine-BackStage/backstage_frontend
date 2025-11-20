import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../authentication/domain/entities/employee.dart';
import '../entities/settings.dart';

abstract class ProfileRepository {
  Future<Either<Failure, Employee>> getEmployeeProfile();
  Future<Either<Failure, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  });
  Future<Either<Failure, Settings>> getSettings();
  Future<Either<Failure, void>> updateSettings(Settings settings);
}
