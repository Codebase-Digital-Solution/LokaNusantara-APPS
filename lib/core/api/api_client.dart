import 'package:dio/dio.dart';

import '../error/errors.dart';

/// HTTP client for the Bali Guide Map REST API.
///
/// Override the base URL at build time with
/// `--dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1`.
class ApiClient {
  ApiClient({String? baseUrl, Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: baseUrl ?? defaultBaseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              headers: {'Content-Type': 'application/json'},
            ),
          ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _token;
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Accept-Language'] = languageCode;
          handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) _token = null;
          handler.next(error);
        },
      ),
    );
  }

  /// Sent as Accept-Language so AI answers come back in the app language.
  String languageCode = 'id';

  static const defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://lokanusantara-api.codebasedigital.id/api/v1',
  );

  /// Headers for loading files (images) straight from the API host. The ngrok
  /// header skips its browser warning page on development tunnels.
  static const mediaHeaders = {'ngrok-skip-browser-warning': 'true'};

  /// Turns a stored media reference into a loadable URL. Uploaded files come
  /// back as "/uploads/..." relative to the API host; full URLs pass through.
  static String? resolveMediaUrl(String? raw, {String base = defaultBaseUrl}) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) return null;
    if (!value.startsWith('/')) return value;
    return Uri.parse(base).resolve(value).toString();
  }

  final Dio _dio;
  String? _token;

  void setToken(String token) => _token = token;
  void clearToken() => _token = null;

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      _send(() => _dio.get(path, queryParameters: query));

  /// [timeout] overrides the default 10s receive timeout for slow calls.
  Future<dynamic> post(String path, {Object? data, Duration? timeout}) => _send(
    () => _dio.post(
      path,
      data: data,
      options: timeout == null ? null : Options(receiveTimeout: timeout),
    ),
  );

  Future<dynamic> put(String path, {Object? data}) =>
      _send(() => _dio.put(path, data: data));

  Future<dynamic> delete(String path) => _send(() => _dio.delete(path));

  Future<dynamic> _send(Future<Response<dynamic>> Function() request) async {
    try {
      final response = await request();
      return response.data;
    } catch (e) {
      throw handleError(e);
    }
  }
}
