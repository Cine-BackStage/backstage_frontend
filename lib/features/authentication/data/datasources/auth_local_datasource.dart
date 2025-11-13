import 'dart:convert';
import '../../../../adapters/storage/local_storage.dart' hide StorageKeys;
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/employee_model.dart';

/// Authentication local data source interface
abstract class AuthLocalDataSource {
  Future<void> cacheToken(String token);
  Future<String?> getCachedToken();
  Future<void> cacheEmployee(EmployeeModel employee);
  Future<EmployeeModel> getCachedEmployee();
  Future<void> clearAuthData();
}

/// Authentication local data source implementation
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final LocalStorage storage;

  AuthLocalDataSourceImpl(this.storage);

  @override
  Future<void> cacheToken(String token) async {
    await storage.setString(StorageKeys.authToken, token);
  }

  @override
  Future<String?> getCachedToken() async {
    return storage.getString(StorageKeys.authToken);
  }

  @override
  Future<void> cacheEmployee(EmployeeModel employee) async {
    // Cache employee data
    await storage.setString(StorageKeys.userCpf, employee.cpf);
    await storage.setString(StorageKeys.userName, employee.fullName);
    await storage.setString(StorageKeys.userRole, employee.role);
    await storage.setString(StorageKeys.userEmail, employee.email);
    await storage.setString(StorageKeys.employeeId, employee.employeeId);
    await storage.setString(StorageKeys.companyId, employee.companyId);

    // Cache full employee object as JSON
    final employeeJson = jsonEncode(employee.toJson());
    await storage.setString('cached_employee', employeeJson);
  }

  @override
  Future<EmployeeModel> getCachedEmployee() async {
    try {
      final employeeJson = storage.getString('cached_employee');
      if (employeeJson == null) {
        throw AppException(message: 'No cached employee found');
      }

      final employeeMap = jsonDecode(employeeJson) as Map<String, dynamic>;
      return EmployeeModel.fromJson(employeeMap);
    } catch (e) {
      throw AppException(message: 'Failed to get cached employee: ${e.toString()}');
    }
  }

  @override
  Future<void> clearAuthData() async {
    await storage.remove(StorageKeys.authToken);
    await storage.remove(StorageKeys.userCpf);
    await storage.remove(StorageKeys.userName);
    await storage.remove(StorageKeys.userRole);
    await storage.remove(StorageKeys.userEmail);
    await storage.remove(StorageKeys.employeeId);
    await storage.remove(StorageKeys.companyId);
    await storage.remove('cached_employee');
  }
}
