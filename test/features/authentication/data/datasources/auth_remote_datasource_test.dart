import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/adapters/http/http_client.dart';
import 'package:backstage_frontend/core/errors/exceptions.dart';
import 'package:backstage_frontend/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:backstage_frontend/features/authentication/data/models/login_request.dart';
import 'package:backstage_frontend/features/authentication/data/models/login_response.dart';

class MockHttpClient extends Mock implements HttpClient {}

void main() {
  late AuthRemoteDataSourceImpl dataSource;
  late MockHttpClient mockHttpClient;

  setUpAll(() {
    registerFallbackValue(LoginRequest(employeeId: '', password: ''));
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = AuthRemoteDataSourceImpl(mockHttpClient);
  });

  final tLoginRequest = LoginRequest(
    employeeId: '12345',
    password: 'password123',
  );

  final tLoginResponseData = {
    'success': true,
    'data': {
      'token': 'test_token_123',
      'employee': {
        'cpf': '123.456.789-00',
        'companyId': 'comp-123',
        'employeeId': '12345',
        'role': 'cashier',
        'fullName': 'John Doe',
        'email': 'john@example.com',
        'isActive': true,
      },
    },
  };

  group('login', () {
    test('should return LoginResponse when the call is successful', () async {
      // Arrange
      when(() => mockHttpClient.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: tLoginResponseData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      final result = await dataSource.login(tLoginRequest);

      // Assert
      expect(result, isA<LoginResponse>());
      expect(result.token, equals('test_token_123'));
      expect(result.employee.employeeId, equals('12345'));
    });

    test('should throw AppException when success is false', () async {
      // Arrange
      when(() => mockHttpClient.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: {
                  'success': false,
                  'message': 'Invalid credentials',
                },
                statusCode: 401,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act & Assert
      expect(
        () => dataSource.login(tLoginRequest),
        throwsA(isA<AppException>()),
      );
    });

    test('should throw AppException when an error occurs', () async {
      // Arrange
      when(() => mockHttpClient.post(any(), data: any(named: 'data')))
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => dataSource.login(tLoginRequest),
        throwsA(isA<AppException>()),
      );
    });
  });
}
