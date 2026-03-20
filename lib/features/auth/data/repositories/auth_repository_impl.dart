import 'package:sweet_mobile_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:sweet_mobile_app/features/auth/domain/entities/auth_user.dart';
import 'package:sweet_mobile_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._ds);

  final AuthRemoteDataSource _ds;

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final model = await _ds.login(email: email, password: password);
    return model.toEntity();
  }

  @override
  Future<AuthUser> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    String role = 'CLIENT',
  }) async {
    final model = await _ds.register(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      role: role,
    );
    return model.toEntity();
  }

  @override
  Future<void> logout({required String refreshToken}) async {
    await _ds.logout(refreshToken: refreshToken);
  }
}
