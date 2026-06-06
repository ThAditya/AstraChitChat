import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/repositories/search_repository.dart';
import '../../domain/models/search_result.dart';

import 'dart:async';

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return SearchRepository(ApiClient());
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final debouncedSearchQueryProvider = StreamProvider<String>((ref) {
  final query = ref.watch(searchQueryProvider);
  final controller = StreamController<String>();

  final timer = Timer(const Duration(milliseconds: 500), () {
    controller.add(query);
  });

  ref.onDispose(() {
    timer.cancel();
    controller.close();
  });

  return controller.stream;
});

final searchResultsProvider = FutureProvider<Map<String, List<dynamic>>>((ref) async {
  final queryAsync = ref.watch(debouncedSearchQueryProvider);

  return queryAsync.when(
    data: (query) async {
      if (query.isEmpty) {
        return {'users': [], 'posts': []};
      }
      final repository = ref.read(searchRepositoryProvider);
      return repository.search(query);
    },
    loading: () => {'users': [], 'posts': []},
    error: (err, stack) => {'users': [], 'posts': []},
  );
});
