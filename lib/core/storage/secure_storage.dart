import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wrapper sobre flutter_secure_storage para tokens JWT.
/// Nunca loguear los valores almacenados aquí.
class SecureStorageService {
  SecureStorageService(this._storage);

  final FlutterSecureStorage _storage;

  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyUserId = 'user_id';
  static const _keyUserRole = 'user_role';

  // ── Tokens ─────────────────────────────────────────────────

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _keyAccessToken, value: accessToken),
      _storage.write(key: _keyRefreshToken, value: refreshToken),
    ]);
  }

  Future<String?> getAccessToken() => _storage.read(key: _keyAccessToken);
  Future<String?> getRefreshToken() => _storage.read(key: _keyRefreshToken);

  // ── Usuario ────────────────────────────────────────────────

  Future<void> saveUserInfo({
    required String userId,
    required String role,
  }) async {
    await Future.wait([
      _storage.write(key: _keyUserId, value: userId),
      _storage.write(key: _keyUserRole, value: role),
    ]);
  }

  Future<String?> getUserId() => _storage.read(key: _keyUserId);
  Future<String?> getUserRole() => _storage.read(key: _keyUserRole);

  // ── Sesión ─────────────────────────────────────────────────

  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearAll() => _storage.deleteAll();
}
