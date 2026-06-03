import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/models/user_profile.dart';

class ProfileRepository {
  final ApiClient _apiClient;

  ProfileRepository(this._apiClient);

  Future<UserProfile> getMyProfile() async {
    try {
      final response = await _apiClient.dio.get('/profile/me');
      return UserProfile.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to fetch profile');
    }
  }

  Future<UserProfile> getUserProfile(String userId) async {
    try {
      final response = await _apiClient.dio.get('/profile/$userId');
      return UserProfile.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to fetch user profile');
    }
  }

  Future<UserProfile> updateProfile({
    String? name,
    String? username,
    String? bio,
    String? location,
    String? website,
    String? pronouns,
    bool? isPrivate,
    DateTime? birthday,
    String? gender,
    List<String>? interests,
    Map<String, String>? socialLinks,
  }) async {
    try {
      final response = await _apiClient.dio.put(
        '/profile/me',
        data: {
          if (name != null) 'name': name,
          if (username != null) 'username': username,
          if (bio != null) 'bio': bio,
          if (location != null) 'location': location,
          if (website != null) 'website': website,
          if (pronouns != null) 'pronouns': pronouns,
          if (isPrivate != null) 'isPrivate': isPrivate,
          if (birthday != null) 'birthday': birthday.toIso8601String(),
          if (gender != null) 'gender': gender,
          if (interests != null) 'interests': interests,
          if (socialLinks != null) 'socialLinks': socialLinks,
        },
      );
      // Backend returns { message: '...', user: { ...SerializedProfile... } }
      return UserProfile.fromJson(response.data['user']);
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to update profile');
    }
  }

  Future<UserProfile> uploadProfilePicture(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });
      final response = await _apiClient.dio.post(
        '/media/upload/profile-picture',
        data: formData,
      );
      // This endpoint returns { success, message, url, publicId }
      // We might need to fetch the profile again or the backend should return the updated user.
      // Looking at mediaRoutes.js, it updates the user and returns success.
      // Let's fetch the profile to get the full updated state.
      return await getMyProfile();
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to upload profile picture');
    }
  }

  Future<UserProfile> uploadCoverPhoto(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });
      final response = await _apiClient.dio.post(
        '/media/upload/cover-photo',
        data: formData,
      );
      return await getMyProfile();
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to upload cover photo');
    }
  }

  String _handleDioError(DioException e, String defaultMessage) {
    if (e.response?.data != null && e.response!.data is Map) {
      final data = e.response!.data;
      if (data['message'] != null) return data['message'];
    }
    return e.message ?? defaultMessage;
  }
}
