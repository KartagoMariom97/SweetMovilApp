import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sweet_mobile_app/core/network/dio_client.dart';
import 'package:sweet_mobile_app/core/storage/secure_storage.dart';
import 'package:sweet_mobile_app/core/storage/local_storage.dart';

// ── Infraestructura ─────────────────────────────────────────

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService(
    const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  );
});

final localStorageProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError('Inicializar con ProviderScope override en main.dart');
});

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(ref.read(secureStorageProvider));
});

// ── Estado de autenticación ─────────────────────────────────

/// Observable que GoRouter usa como refreshListenable.
class AuthState extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _role;

  bool get isLoggedIn => _isLoggedIn;
  String? get role => _role;

  void setLoggedIn({required String role}) {
    _isLoggedIn = true;
    _role = role;
    notifyListeners();
  }

  void setLoggedOut() {
    _isLoggedIn = false;
    _role = null;
    notifyListeners();
  }
}

final authStateProvider = ChangeNotifierProvider<AuthState>((ref) {
  return AuthState();
});
