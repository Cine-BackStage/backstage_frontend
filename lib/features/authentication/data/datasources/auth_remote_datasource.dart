import '../models/user_dto.dart';
import '../models/login_response_dto.dart';
import '../../domain/errors/auth_exceptions.dart';

/// Abstract remote data source for authentication
abstract class AuthRemoteDataSource {
  Future<LoginResponseDto> login(String cpf, String password);
  Future<void> requestPasswordReset(String cpf);
}

/// Mocked implementation of remote data source
/// TODO: Replace with real API calls when backend is ready
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  // Mocked users for testing
  static const _mockedUsers = {
    '123.456.789-00': {
      'password': 'admin123',
      'user': {
        'id': '1',
        'cpf': '123.456.789-00',
        'name': 'Admin Silva',
        'role': 'admin',
        'cinema_id': 'cinema-1',
        'cinema_name': 'Cinema Central',
      },
    },
    '987.654.321-00': {
      'password': 'employee123',
      'user': {
        'id': '2',
        'cpf': '987.654.321-00',
        'name': 'João Funcionário',
        'role': 'employee',
        'cinema_id': 'cinema-1',
        'cinema_name': 'Cinema Central',
      },
    },
    '111.222.333-44': {
      'password': 'test123',
      'user': {
        'id': '3',
        'cpf': '111.222.333-44',
        'name': 'Maria Teste',
        'role': 'employee',
        'cinema_id': 'cinema-2',
        'cinema_name': 'Cinema Shopping',
      },
    },
  };

  @override
  Future<LoginResponseDto> login(String cpf, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // TODO: Replace with real API call
    // Example: final response = await httpClient.post('/auth/login', data: {...});

    final userData = _mockedUsers[cpf];

    if (userData == null || userData['password'] != password) {
      throw const InvalidCredentialsException();
    }

    final user = UserDto.fromJson(userData['user'] as Map<String, dynamic>);
    final token = 'mock_token_${user.id}_${DateTime.now().millisecondsSinceEpoch}';

    return LoginResponseDto(
      token: token,
      user: user,
      expiresIn: 86400, // 24 hours
    );
  }

  @override
  Future<void> requestPasswordReset(String cpf) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // TODO: Replace with real API call to send reset email/SMS
    // Example: await httpClient.post('/auth/reset-password', data: {'cpf': cpf});

    // Check if user exists
    if (!_mockedUsers.containsKey(cpf)) {
      throw const UserNotFoundException();
    }

    // Mock success
    // In real implementation, this would send an email/SMS
  }
}
