import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/models/search_result.dart';

class SearchRepository {
  final ApiClient _apiClient;

  SearchRepository(this._apiClient);

  Future<Map<String, List<dynamic>>> search(String query) async {
    try {
      final response = await _apiClient.dio.get(
        '/search',
        queryParameters: {'q': query},
      );

      if (response.statusCode == 200) {
        final List<dynamic> usersData = response.data['users'] ?? [];
        final List<dynamic> postsData = response.data['posts'] ?? [];

        return {
          'users': usersData,
          'posts': postsData,
        };
      } else {
        throw Exception('Failed to search');
      }
    } catch (e) {
      rethrow;
    }
  }
}
