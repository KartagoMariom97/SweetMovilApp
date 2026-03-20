import 'package:sweet_mobile_app/core/network/dio_client.dart';

class ProfileDataSource {
  const ProfileDataSource(this._client);
  final DioClient _client;

  Future<Map<String, dynamic>> getMyProfile() async {
    return _client.get<Map<String, dynamic>>(
      '/users/profile',
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    await _client.patch<Map<String, dynamic>>(
      '/users/profile',
      data: data,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }
}
