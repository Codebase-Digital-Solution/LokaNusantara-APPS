import 'package:bali_guide_map/core/error/errors.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

DioException httpError(int status, Object? body) {
  final req = RequestOptions(path: '/x');
  return DioException(
    requestOptions: req,
    response: Response(requestOptions: req, statusCode: status, data: body),
    type: DioExceptionType.badResponse,
  );
}

void main() {
  test('returns AppError unchanged', () {
    const e = NotFoundError('gone');
    expect(handleError(e), same(e));
  });

  test('maps HTTP status codes and reads the API error message', () {
    expect(
      handleError(httpError(401, {'error': 'bad token'})),
      isA<UnauthorizedError>().having((e) => e.message, 'message', 'bad token'),
    );
    expect(handleError(httpError(404, null)), isA<NotFoundError>());
    expect(handleError(httpError(400, {'error': 'x'})), isA<ValidationError>());
    expect(handleError(httpError(500, null)), isA<ServerError>());
    expect(handleError(httpError(418, null)).code, 'HTTP_418');
  });

  test('maps connection failures to NetworkError', () {
    final e = DioException(
      requestOptions: RequestOptions(path: '/x'),
      type: DioExceptionType.connectionError,
    );
    expect(handleError(e), isA<NetworkError>());
  });

  test('maps ArgumentError to ValidationError', () {
    expect(
      handleError(ArgumentError('nope')),
      isA<ValidationError>().having((e) => e.message, 'message', 'nope'),
    );
  });
}
