import 'package:dio/dio.dart';
import 'package:sweet_mobile_app/core/config/app_config.dart';
import 'package:sweet_mobile_app/core/error/failures.dart';
import 'package:sweet_mobile_app/core/network/auth_interceptor.dart';
import 'package:sweet_mobile_app/core/storage/secure_storage.dart';

class DioClient {
  DioClient(SecureStorageService storage) {
    // Dio base sin interceptores (para el refresh dentro del AuthInterceptor)
    final baseDio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(AuthInterceptor(storage, baseDio));

    if (AppConfig.logRequests) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ));
    }
  }

  late final Dio _dio;

  Dio get instance => _dio;

  // ── Helpers ────────────────────────────────────────────────

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final res = await _dio.get<dynamic>(path, queryParameters: queryParams);
      return fromJson != null ? fromJson(res.data) : res.data as T;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<T> post<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final res = await _dio.post<dynamic>(path, data: data);
      return fromJson != null ? fromJson(res.data) : res.data as T;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<T> patch<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final res = await _dio.patch<dynamic>(path, data: data);
      return fromJson != null ? fromJson(res.data) : res.data as T;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> delete(String path) async {
    try {
      await _dio.delete<dynamic>(path);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  // ── Mapeo de errores ───────────────────────────────────────

  Failure _mapError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkFailure();
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        final message = _extractMessage(e.response?.data);
        return switch (status) {
          401 => const AuthFailure(),
          404 => NotFoundFailure(message),
          400 || 422 => ValidationFailure(message),
          _ => ServerFailure(message, statusCode: status),
        };
      default:
        return const UnknownFailure();
    }
  }

  String _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return (data['message'] as String?) ?? 'Error del servidor';
    }
    return 'Error del servidor';
  }
}
