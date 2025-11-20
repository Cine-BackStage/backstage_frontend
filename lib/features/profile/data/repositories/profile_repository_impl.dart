import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../authentication/domain/entities/employee.dart';
import '../../../authentication/data/datasources/auth_local_datasource.dart';
import '../../domain/entities/settings.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_datasource.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/settings_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource localDataSource;
  final ProfileRemoteDataSource remoteDataSource;
  final AuthLocalDataSource authLocalDataSource;

  ProfileRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.authLocalDataSource,
  });

  @override
  Future<Either<Failure, Employee>> getEmployeeProfile() async {
    try {
      final employeeModel = await authLocalDataSource.getCachedEmployee();
      // EmployeeModel already extends Employee, so we can return it directly
      return Right(employeeModel);
    } catch (e) {
      return Left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return const Right(null);
    } catch (e) {
      return Left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Settings>> getSettings() async {
    try {
      final settings = await localDataSource.getSettings();
      return Right(settings.toEntity());
    } catch (e) {
      return Left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> updateSettings(Settings settings) async {
    try {
      final settingsModel = SettingsModel(
        language: settings.language,
        theme: settings.theme,
        notifications: settings.notifications,
      );
      await localDataSource.saveSettings(settingsModel);
      return const Right(null);
    } catch (e) {
      return Left(ErrorMapper.fromException(e));
    }
  }
}
