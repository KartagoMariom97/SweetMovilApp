/// Entidad de dominio — resultado exitoso de auth (login / register).
/// No contiene lógica, solo datos puros del negocio.
class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.role,
    required this.accessToken,
    required this.refreshToken,
  });

  final String id;
  final String email;
  final String role; // 'CLIENT' | 'PROVIDER' | 'ADMIN'
  final String accessToken;
  final String refreshToken;

  bool get isProvider => role == 'PROVIDER';
  bool get isAdmin => role == 'ADMIN';
}
