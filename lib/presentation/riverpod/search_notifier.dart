import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/search_repositories.dart';
import 'providers.dart';
import 'search_state.dart';

class SearchNotifier extends AsyncNotifier<SearchState> {
  static const _pageSize = 20;

  late final SearchRepositories _searchRepositories;

  bool _isFetchingNextPage = false;

  @override
  Future<SearchState> build() {
    _searchRepositories = ref.read(searchRepositoriesProvider);
    return Future.value(const SearchState.initial());
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      state = const AsyncData(SearchState.initial());
      return;
    }

    state = const AsyncLoading();
    final result = await _searchRepositories(query: query, page: 1);
    state = result.when(
      success: (repos) => AsyncData(
        SearchState(
          query: query,
          repos: repos,
          page: 1,
          hasReachedMax: repos.length < _pageSize,
        ),
      ),
      error: (failure) => AsyncError(failure, StackTrace.current),
    );
  }

  Future<void> loadNextPage() async {
    if (_isFetchingNextPage) return;

    final current = state.value;

    if (current == null || current.hasReachedMax || current.query.isEmpty) {
      return;
    }
    _isFetchingNextPage = true;

    final nextPage = current.page + 1;
    final result = await _searchRepositories(
      query: current.query,
      page: nextPage,
    );

    state = result.when(
      success: (repos) => AsyncData(
        current.copyWith(
          repos: [...current.repos, ...repos],
          page: nextPage,
          hasReachedMax: repos.length < _pageSize,
        ),
      ),
      error: (failure) => AsyncError(failure, StackTrace.current),
    );
    _isFetchingNextPage = false;
  }
}

final searchNotifierProvider =
    AsyncNotifierProvider<SearchNotifier, SearchState>(SearchNotifier.new);
