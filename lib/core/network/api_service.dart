import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../constants/api_constants.dart';
import '../storage/secure_storage_service.dart';
import '../utils/app_logger.dart';

/// Ek hi jagah se saari API calls — GET/POST/PUT/DELETE.
/// Token automatically har request me attach ho jaata hai (interceptor se).
class ApiService {
  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
        receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
        sendTimeout: const Duration(milliseconds: ApiConstants.sendTimeout),
        headers: {
          ApiConstants.contentTypeHeader: 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStorageService.instance.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers[ApiConstants.authHeader] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          AppLogger.e(
            '${error.requestOptions.method} ${error.requestOptions.path} failed',
            error,
            error.stackTrace,
          );
          // 🔧 Yahan 401 -> refresh token logic add kar sakte ho baad me
          return handler.next(error);
        },
      ),
    );

    // Clean, colored request/response logs — sirf debug builds me chalega
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
        compact: true,
        maxWidth: 120,
      ),
    );
  }

  static final ApiService instance = ApiService._internal();
  late final Dio _dio;

  /// Render's free tier sleeps the backend when idle — the very first
  /// request after that can time out even though the server is fine and
  /// just needs a moment to spin up. Retry once automatically so the user
  /// isn't shown an error for something that resolves itself in a few
  /// seconds.
  Future<Response> _withColdStartRetry(Future<Response> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      final isTimeout = e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout;
      if (!isTimeout) rethrow;

      AppLogger.w('${e.requestOptions.method} ${e.requestOptions.path} timed out — '
          'retrying once in case the server was waking up.');
      return await call();
    }
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _withColdStartRetry(() => _dio.get(path, queryParameters: queryParameters));
  }

  Future<Response> post(String path, {dynamic data}) {
    return _withColdStartRetry(() => _dio.post(path, data: data));
  }

  Future<Response> put(String path, {dynamic data}) {
    return _withColdStartRetry(() => _dio.put(path, data: data));
  }

  Future<Response> delete(String path, {dynamic data}) {
    return _withColdStartRetry(() => _dio.delete(path, data: data));
  }
}
