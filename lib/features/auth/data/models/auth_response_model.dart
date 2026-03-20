import 'package:sweet_mobile_app/features/auth/domain/entities/auth_user.dart';

/// DTO que mapea la respuesta JSON del backend.
/// { accessToken, refreshToken, user: { id, email, role } }
class AuthResponseModel {
  const AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.email,
    required this.role,
  });

  final String accessToken;
  final String refreshToken;
  final String userId;
  final String email;
  final String role;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    return AuthResponseModel(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      userId: user['id'] as String,
      email: user['email'] as String,
      role: user['role'] as String,
    );
  }

  AuthUser toEntity() => AuthUser(
        id: userId,
        email: email,
        role: role,
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
}
