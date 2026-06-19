import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String? deviceId,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          if (deviceId != null) 'deviceId': deviceId,
        },
      );
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e, 'Registration failed');
    }
  }

  Future<UserModel> login({
    required String email,
    required String password,
    String? deviceId,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
          if (deviceId != null) 'deviceId': deviceId,
        },
      );
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e, 'Login failed');
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _apiClient.dio.post(
        '/auth/forgot-password',
        data: {'email': email},
      );
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to request reset code');
    }
  }

  Future<String> verifyResetCode(String email, String code) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/verify-reset-code',
        data: {'email': email, 'code': code},
      );
      return response.data['resetToken'];
    } on DioException catch (e) {
      throw _handleDioError(e, 'Invalid or expired code');
    }
  }

  Future<void> resetPassword(String resetToken, String password) async {
    try {
      await _apiClient.dio.post(
        '/auth/reset-password',
        data: {'resetToken': resetToken, 'password': password},
      );
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to reset password');
    }
  }

  String _handleDioError(DioException e, String defaultMessage) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.receiveTimeout) {
      final url = e.requestOptions.uri.toString();
      return 'Cannot connect to backend.\nTarget: $url\n\n1. Ensure PC Firewall allows port 5000\n2. Check if Phone & PC are on same Wi-Fi';
    }

    if (e.response?.data != null && e.response!.data is Map) {
      final data = e.response!.data;

      // 1. Check for Joi Validation Errors (Map of fields)
      if (data['errors'] != null && data['errors'] is Map) {
        final Map<String, dynamic> errors = Map<String, dynamic>.from(data['errors']);
        return errors.values.map((e) => (e as List).join(', ')).join('\n');
      }

      // 2. Check for Top-level Message
      if (data['message'] != null) {
        return data['message'];
      }
    }

    return e.message ?? defaultMessage;
  }
}
