import 'package:dio/dio.dart';

class AppError implements Exception {
  const AppError(this.message, [this.code = 'UNKNOWN_ERROR']);

  final String message;
  final String code;

  static const defaultMessage = 'Terjadi kesalahan';

  @override
  String toString() => message;
}

class NetworkError extends AppError {
  static const defaultMessage = 'Koneksi jaringan gagal';

  const NetworkError([String message = defaultMessage])
    : super(message, 'NETWORK_ERROR');
}

class NotFoundError extends AppError {
  static const defaultMessage = 'Data tidak ditemukan';

  const NotFoundError([String message = defaultMessage])
    : super(message, 'NOT_FOUND');
}

class UnauthorizedError extends AppError {
  static const defaultMessage = 'Akses tidak diizinkan';

  /// Thrown when saving a place or a plan while signed out.
  static const signInToSavePlace = 'Masuk dulu untuk menyimpan destinasi';
  static const signInToSavePlan = 'Masuk dulu untuk menyimpan rencana';

  const UnauthorizedError([String message = defaultMessage])
    : super(message, 'UNAUTHORIZED');
}

class ValidationError extends AppError {
  static const defaultMessage = 'Validasi gagal';

  const ValidationError([String message = defaultMessage])
    : super(message, 'VALIDATION_ERROR');
}

class ServerError extends AppError {
  static const defaultMessage = 'Terjadi kesalahan pada server';

  const ServerError([String message = defaultMessage])
    : super(message, 'SERVER_ERROR');
}

/// Converts any thrown object into an [AppError].
AppError handleError(Object error) {
  if (error is AppError) return error;

  if (error is DioException) {
    final response = error.response;
    if (response != null) {
      final data = response.data;
      final message = (data is Map && data['error'] is String)
          ? data['error'] as String
          : (error.message ?? 'HTTP ${response.statusCode}');
      switch (response.statusCode) {
        case 400:
        case 422:
          return ValidationError(message);
        case 401:
          return UnauthorizedError(message);
        case 404:
          return NotFoundError(message);
        case 500:
          return ServerError(message);
        default:
          return AppError(message, 'HTTP_${response.statusCode}');
      }
    }
    switch (error.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const NetworkError();
      default:
        return AppError(error.message ?? AppError.defaultMessage);
    }
  }

  if (error is ArgumentError) {
    return ValidationError(error.message?.toString() ?? 'Validasi gagal');
  }

  return AppError(error.toString());
}
