import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sweet_mobile_app/core/di/providers.dart';
import 'package:sweet_mobile_app/core/error/failures.dart';
import 'package:sweet_mobile_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:sweet_mobile_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:sweet_mobile_app/features/auth/domain/entities/auth_user.dart';
import 'package:sweet_mobile_app/features/auth/domain/repositories/auth_repository.dart';

// ── Providers de infraestructura ───────────────────────────────────────────────

final _authRemoteDsProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.read(dioClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(_authRemoteDsProvider));
});

// ── Estado de la UI ────────────────────────────────────────────────────────────

sealed class AuthFormState {}
final class AuthFormIdle extends AuthFormState {}
final class AuthFormLoading extends AuthFormState {}
final class AuthFormSuccess extends AuthFormState {
  AuthFormSuccess(this.user);
  final AuthUser user;
}
final class AuthFormError extends AuthFormState {
  AuthFormError(this.message);
  final String message;
}

// ── Notifier ───────────────────────────────────────────────────────────────────

class AuthNotifier extends Notifier<AuthFormState> {
  @override
  AuthFormState build() => AuthFormIdle();

  AuthRepository get _repo => ref.read(authRepositoryProvider);
  AuthState get _authState => ref.read(authStateProvider);
  SecureStorageService get _storage => ref.read(secureStorageProvider);

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = AuthFormLoading();
    try {
      final user = await _repo.login(email: email, password: password);
      await _persistSession(user);
      state = AuthFormSuccess(user);
      return true;
    } on Failure catch (f) {
      state = AuthFormError(f.message);
      return false;
    } catch (_) {
      state = AuthFormError('Ocurrió un error inesperado. Intenta nuevamente.');
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    String role = 'CLIENT',
  }) async {
    state = AuthFormLoading();
    try {
      final user = await _repo.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        role: role,
      );
      await _persistSession(user);
      state = AuthFormSuccess(user);
      return true;
    } on Failure catch (f) {
      state = AuthFormError(f.message);
      return false;
    } catch (_) {
      state = AuthFormError('Ocurrió un error inesperado. Intenta nuevamente.');
      return false;
    }
  }

  Future<void> logout() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken != null) {
      try {
        await _repo.logout(refreshToken: refreshToken);
      } catch (_) {
        // Siempre limpiar localmente aunque falle el servidor
      }
    }
    await _storage.clearAll();
    _authState.setLoggedOut();
    state = AuthFormIdle();
  }

  void resetError() {
    if (state is AuthFormError) state = AuthFormIdle();
  }

  Future<void> _persistSession(AuthUser user) async {
    await _storage.saveTokens(
      accessToken: user.accessToken,
      refreshToken: user.refreshToken,
    );
    await _storage.saveUserInfo(userId: user.id, role: user.role);
    _authState.setLoggedIn(role: user.role);
  }
}

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AuthFormState>(AuthNotifier.new);
