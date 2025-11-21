import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/adapters/http/http_client.dart';
import 'package:backstage_frontend/features/profile/data/datasources/profile_remote_datasource.dart';

class MockHttpClient extends Mock implements HttpClient {}

void main() {
  late ProfileRemoteDataSourceImpl dataSource;
  late MockHttpClient mockClient;

  setUp(() {
    mockClient = MockHttpClient();
    dataSource = ProfileRemoteDataSourceImpl(mockClient);
  });

  const tCurrentPassword = 'oldPassword123';
  const tNewPassword = 'newPassword456';

  group('changePassword', () {
    test('should complete successfully when password change succeeds', () async {
      // Act
      await dataSource.changePassword(
        currentPassword: tCurrentPassword,
        newPassword: tNewPassword,
      );

      // Assert - no exception thrown means success
      // Note: Current implementation simulates success with a delay
    });

    test('should complete within reasonable time', () async {
      // Act
      final stopwatch = Stopwatch()..start();
      await dataSource.changePassword(
        currentPassword: tCurrentPassword,
        newPassword: tNewPassword,
      );
      stopwatch.stop();

      // Assert
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });
  });
}
