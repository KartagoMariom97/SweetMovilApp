import 'package:sweet_mobile_app/features/auth/domain/entities/auth_user.dart';

/// Contrato que el dominio espera. La implementación vive en la capa de datos.
abstract interface class AuthRepository {
  Future<AuthUser> login({
    required String email,
    required String password,
  });

  Future<AuthUser> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    String role,
  });

  Future<void> logout({required String refreshToken});
}
