import '../../../../adapters/http/http_client.dart';

abstract class ProfileRemoteDataSource {
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final HttpClient client;

  ProfileRemoteDataSourceImpl(this.client);

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    // await client.put(
    //   '/api/employees/password',
    //   data: {
    //     'currentPassword': currentPassword,
    //     'newPassword': newPassword,
    //   },
    // );

    // For now, simulate success
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
