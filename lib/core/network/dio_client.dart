import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage.dart';

class JwtInterceptor extends Interceptor {
  final Dio dio;
  final SecureStorageService storage;

  JwtInterceptor({required this.dio, required this.storage});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await storage.getAccessToken();
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
    // Only attempt refresh on 401 errors that are NOT from the refresh endpoint
    if (err.response?.statusCode == 401 &&
        !(err.requestOptions.path.contains('/auth/refresh'))) {
      try {
        final refreshToken = await storage.getRefreshToken();
        if (refreshToken == null) {
          await storage.clearTokens();
          handler.next(err);
          return;
        }

        // Call refresh endpoint with the refresh token in the header
        final refreshDio = Dio(
          BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            headers: {'Authorization': 'Bearer $refreshToken'},
          ),
        );
        final refreshResponse = await refreshDio.post(ApiConstants.refresh);

        final newAccessToken = refreshResponse.data['accessToken'] as String;
        final newRefreshToken = refreshResponse.data['refreshToken'] as String;

        await storage.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );

        // Retry original request with new token
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer $newAccessToken';
        final retryResponse = await dio.fetch(opts);
        handler.resolve(retryResponse);
        return;
      } catch (_) {
        await storage.clearTokens();
      }
    }
    handler.next(err);
  }
}

Dio createDio(SecureStorageService storage) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(JwtInterceptor(dio: dio, storage: storage));

  // Debug logging in development
  dio.interceptors.add(
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ),
  );

  return dio;
}
