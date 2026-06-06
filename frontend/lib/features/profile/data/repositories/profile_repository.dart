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

  Future<List<Map<String, dynamic>>> getFollowers(String userId) async {
    try {
      final response = await _apiClient.dio.get('/follow/$userId/followers');
      // Response structure: { followers: [...], count: 0, hasMore: false }
      return List<Map<String, dynamic>>.from(response.data['followers']);
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to fetch followers');
    }
  }

  Future<List<Map<String, dynamic>>> getFollowing(String userId) async {
    try {
      final response = await _apiClient.dio.get('/follow/$userId/following');
      // Response structure: { following: [...], count: 0, hasMore: false }
      return List<Map<String, dynamic>>.from(response.data['following']);
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to fetch following');
    }
  }

  Future<void> followUser(String userId) async {
    try {
      await _apiClient.dio.post('/follow/$userId');
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to follow user');
    }
  }

  Future<void> unfollowUser(String userId) async {
    try {
      await _apiClient.dio.delete('/follow/$userId');
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to unfollow user');
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
