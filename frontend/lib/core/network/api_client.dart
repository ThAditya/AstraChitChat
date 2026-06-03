import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  // 1. FOR EMULATOR: Use "http://10.0.2.2:5000/api"
  // 2. FOR PHYSICAL DEVICE: Use your PC's IP (e.g., "http://192.168.1.15:5000/api")
  static const String baseUrl = "http://192.168.1.7:5000/api";

  late Dio _dio;
  bool _isRefreshing = false;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('accessToken');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          // Token Expiration Handling (401 Unauthorized)
          if (e.response?.statusCode == 401 && !_isRefreshing) {
            _isRefreshing = true;
            try {
              final newTokens = await _refreshToken();
              if (newTokens != null) {
                // Retry the original request with new token
                e.requestOptions.headers['Authorization'] = 'Bearer ${newTokens['accessToken']}';

                final response = await _dio.request(
                  e.requestOptions.path,
                  data: e.requestOptions.data,
                  queryParameters: e.requestOptions.queryParameters,
                  options: Options(
                    method: e.requestOptions.method,
                    headers: e.requestOptions.headers,
                  ),
                );
                _isRefreshing = false;
                return handler.resolve(response);
              }
            } catch (refreshError) {
              _isRefreshing = false;
              // If refresh fails, clear storage
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('accessToken');
              await prefs.remove('refreshToken');
            }
          }
          _isRefreshing = false;
          return handler.next(e);
        },
      ),
    );
  }

  Future<Map<String, dynamic>?> _refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refreshToken');
    if (refreshToken == null) return null;

    try {
      // New Dio instance to avoid interceptor recursion
      final refreshDio = Dio(BaseOptions(baseUrl: baseUrl));
      final response = await refreshDio.post(
        '/auth/refresh-token',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        await prefs.setString('accessToken', data['accessToken']);
        await prefs.setString('refreshToken', data['refreshToken']);
        return data;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Dio get dio => _dio;
}
