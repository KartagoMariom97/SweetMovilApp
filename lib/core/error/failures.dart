/// Jerarquía de fallos para el sistema de manejo de errores.
sealed class Failure {
  const Failure(this.message);
  final String message;
}

/// Error de red — sin conexión, timeout, etc.
final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Sin conexión. Verifica tu internet.']);
}

/// Error de servidor — 4xx / 5xx
final class ServerFailure extends Failure {
  const ServerFailure(super.message, {this.statusCode});
  final int? statusCode;
}

/// Sesión expirada — token inválido o revocado
final class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Sesión expirada. Inicia sesión nuevamente.']);
}

/// Recurso no encontrado — 404
final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Recurso no encontrado.']);
}

/// Error de validación — 422 / 400
final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Error desconocido
final class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Ocurrió un error inesperado.']);
}
