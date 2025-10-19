import '../../../../adapters/storage/local_storage.dart';
import '../models/user_dto.dart';

/// Abstract local data source for authentication
abstract class AuthLocalDataSource {
  Future<void> saveAuthToken(String token, DateTime expiresAt);
  Future<String?> getAuthToken();
  Future<void> saveUser(UserDto user);
  Future<UserDto?> getUser();
  Future<void> clearAuth();
  Future<bool> isTokenExpired();
}

/// Implementation of local data source using SharedPreferences
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final LocalStorage storage;

  const AuthLocalDataSourceImpl(this.storage);

  @override
  Future<void> saveAuthToken(String token, DateTime expiresAt) async {
    // TODO: Consider using flutter_secure_storage for production
    await storage.setString(StorageKeys.authToken, token);
    await storage.setString(
      'auth_token_expiry',
      expiresAt.toIso8601String(),
    );
  }

  @override
  Future<String?> getAuthToken() async {
    return storage.getString(StorageKeys.authToken);
  }

  @override
  Future<void> saveUser(UserDto user) async {
    await storage.setString(StorageKeys.userId, user.id);
    await storage.setString(StorageKeys.userCpf, user.cpf);
    await storage.setString(StorageKeys.userName, user.name);
    await storage.setString(StorageKeys.userRole, user.role);
    if (user.cinemaId != null) {
      await storage.setString(StorageKeys.cinemaId, user.cinemaId!);
    }
    if (user.cinemaName != null) {
      await storage.setString(StorageKeys.cinemaName, user.cinemaName!);
    }
  }

  @override
  Future<UserDto?> getUser() async {
    final userId = storage.getString(StorageKeys.userId);
    if (userId == null) return null;

    final cpf = storage.getString(StorageKeys.userCpf);
    final name = storage.getString(StorageKeys.userName);
    final role = storage.getString(StorageKeys.userRole);

    if (cpf == null || name == null || role == null) return null;

    return UserDto(
      id: userId,
      cpf: cpf,
      name: name,
      role: role,
      cinemaId: storage.getString(StorageKeys.cinemaId),
      cinemaName: storage.getString(StorageKeys.cinemaName),
    );
  }

  @override
  Future<void> clearAuth() async {
    await storage.remove(StorageKeys.authToken);
    await storage.remove('auth_token_expiry');
    await storage.remove(StorageKeys.userId);
    await storage.remove(StorageKeys.userCpf);
    await storage.remove(StorageKeys.userName);
    await storage.remove(StorageKeys.userRole);
    await storage.remove(StorageKeys.cinemaId);
    await storage.remove(StorageKeys.cinemaName);
  }

  @override
  Future<bool> isTokenExpired() async {
    final expiryString = storage.getString('auth_token_expiry');
    if (expiryString == null) return true;

    try {
      final expiryDate = DateTime.parse(expiryString);
      return DateTime.now().isAfter(expiryDate);
    } catch (e) {
      return true;
    }
  }
}
