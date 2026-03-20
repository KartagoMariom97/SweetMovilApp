import 'package:dio/dio.dart';
import 'package:sweet_mobile_app/core/storage/secure_storage.dart';

/// Interceptor que:
/// 1. Agrega el Bearer token a cada request
/// 2. En 401, intenta renovar con refresh token
/// 3. Si el refresh falla, limpia la sesión
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage, this._dio);

  final SecureStorageService _storage;
  final Dio _dio; // Dio sin interceptor para el refresh

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Intentar refresh
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null) {
        await _storage.clearAll();
        return handler.next(err);
      }

      final response = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final data = response.data as Map<String, dynamic>;
      await _storage.saveTokens(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
      );

      // Reintentar el request original con el nuevo token
      final opts = err.requestOptions;
      opts.headers['Authorization'] = 'Bearer ${data['accessToken']}';
      final retryResponse = await _dio.fetch(opts);
      return handler.resolve(retryResponse);
    } catch (_) {
      await _storage.clearAll();
      handler.next(err);
    }
  }
}
