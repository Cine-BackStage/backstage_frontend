import '../../../../adapters/http/http_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';

/// Authentication remote data source interface
abstract class AuthRemoteDataSource {
  Future<LoginResponse> login(LoginRequest request);
}

/// Authentication remote data source implementation
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final HttpClient client;

  AuthRemoteDataSourceImpl(this.client);

  @override
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await client.post(
        ApiConstants.login,
        data: request.toJson(),
      );

      // Check if response is successful
      if (response.data['success'] == true) {
        // Log successful response for debugging
        print('[Auth Remote] Login successful: ${response.data}');
        return LoginResponse.fromJson(response.data['data']);
      } else {
        throw AppException(
          message: response.data['message'] ?? 'Login failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      // Log detailed error to console
      print('[Auth Remote Error] ${e.toString()}');
      if (e is AppException) {
        rethrow;
      }
      throw AppException(
        message: e.toString(),
      );
    }
  }
}
