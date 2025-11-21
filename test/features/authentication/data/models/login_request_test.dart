import 'package:flutter_test/flutter_test.dart';
import 'package:backstage_frontend/features/authentication/data/models/login_request.dart';

void main() {
  const tEmployeeId = '12345';
  const tPassword = 'password123';

  final tLoginRequest = LoginRequest(
    employeeId: tEmployeeId,
    password: tPassword,
  );

  group('toJson', () {
    test('should return a JSON map containing proper data', () {
      // Act
      final result = tLoginRequest.toJson();

      // Assert
      final expectedMap = {
        'employeeId': tEmployeeId,
        'password': tPassword,
      };
      expect(result, equals(expectedMap));
    });
  });
}
