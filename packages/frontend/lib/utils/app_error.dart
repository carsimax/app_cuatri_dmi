import '../models/api_response.dart';

/// Clase personalizada para manejar errores de la aplicación
class AppError implements Exception {
  final String message;
  final String? code;
  final int? statusCode;
  final dynamic details;

  const AppError({
    required this.message,
    this.code,
    this.statusCode,
    this.details,
  });

  /// Crea un error desde una ApiError del backend
  factory AppError.fromApiError(ApiError apiError) {
    return AppError(
      message: apiError.message,
      code: apiError.code,
      statusCode: apiError.statusCode,
      details: apiError.details,
    );
  }

  /// Crea un error de red
  factory AppError.network() {
    return const AppError(
      message: 'Error de conexión. Verifica tu internet.',
      code: 'NETWORK_ERROR',
    );
  }

  /// Crea un error de servidor
  factory AppError.server() {
    return const AppError(
      message: 'Error del servidor. Intenta más tarde.',
      code: 'SERVER_ERROR',
    );
  }

  /// Crea un error desconocido
  factory AppError.unknown() {
    return const AppError(
      message: 'Error inesperado. Intenta nuevamente.',
      code: 'UNKNOWN_ERROR',
    );
  }

  /// Crea un error de validación
  factory AppError.validation(String message) {
    return AppError(
      message: message,
      code: 'VALIDATION_ERROR',
    );
  }

  /// Crea un error de autenticación
  factory AppError.authentication(String message) {
    return AppError(
      message: message,
      code: 'AUTH_ERROR',
    );
  }

  @override
  String toString() {
    return message;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppError &&
        other.message == message &&
        other.code == code &&
        other.statusCode == statusCode;
  }

  @override
  int get hashCode {
    return message.hashCode ^ code.hashCode ^ statusCode.hashCode;
  }
}
