import '../../core/error/errors.dart';

/// Runs [body] and rethrows any failure as an [AppError].
Future<T> guard<T>(Future<T> Function() body) async {
  try {
    return await body();
  } catch (e) {
    throw handleError(e);
  }
}
