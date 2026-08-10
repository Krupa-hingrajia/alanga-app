import 'package:dio/dio.dart';
import '../storage/secure_storage_service.dart';
import 'api_endpoints.dart';

class DioInterceptor extends Interceptor {
  final SecureStorageService _storageService;
  final Dio _refreshDio;

  DioInterceptor(this._storageService, this._refreshDio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.path != ApiEndpoints.register &&
        options.path != ApiEndpoints.login) {
      final token = await _storageService.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    return handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 &&
        err.requestOptions.path != ApiEndpoints.login &&
        err.requestOptions.path != ApiEndpoints.register &&
        err.requestOptions.path != ApiEndpoints.refresh) {
      
      try {
        final refreshToken = await _storageService.getRefreshToken();
        if (refreshToken != null) {
          final response = await _refreshDio.post(
            ApiEndpoints.refresh,
            data: {'refreshToken': refreshToken},
            options: Options(
              headers: {'Authorization': 'Bearer $refreshToken'},
            ),
          );

          if (response.statusCode == 200 || response.statusCode == 201) {
            final responseData = response.data;
            final data = responseData['data'];
            final newAccessToken = data['accessToken'] as String;
            final newRefreshToken = data['refreshToken'] as String;

            await _storageService.saveAccessToken(newAccessToken);
            await _storageService.saveRefreshToken(newRefreshToken);

            final retryOptions = err.requestOptions;
            retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';

            final retryDio = Dio(
              BaseOptions(
                baseUrl: retryOptions.baseUrl,
                headers: retryOptions.headers,
              ),
            );

            final retryResponse = await retryDio.request(
              retryOptions.path,
              data: retryOptions.data,
              queryParameters: retryOptions.queryParameters,
              options: Options(
                method: retryOptions.method,
                contentType: retryOptions.contentType,
              ),
            );

            return handler.resolve(retryResponse);
          }
        }
      } catch (e) {
        await _storageService.clearAll();
      }
    }
    return handler.next(err);
  }
}
