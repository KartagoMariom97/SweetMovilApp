import 'package:sweet_mobile_app/core/network/dio_client.dart';
import 'package:sweet_mobile_app/features/auth/data/models/auth_response_model.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._client);

  final DioClient _client;

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final data = await _client.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
      fromJson: (json) => json as Map<String, dynamic>,
    );
    return AuthResponseModel.fromJson(data);
  }

  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    String role = 'CLIENT',
  }) async {
    final data = await _client.post<Map<String, dynamic>>(
      '/auth/register',
      data: {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        'role': role,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
    return AuthResponseModel.fromJson(data);
  }

  Future<void> logout({required String refreshToken}) async {
    await _client.post<void>(
      '/auth/logout',
      data: {'refreshToken': refreshToken},
    );
  }
}
