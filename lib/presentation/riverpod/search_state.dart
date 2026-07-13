import 'package:equatable/equatable.dart';

import '../../domain/entities/github_repo.dart';

class SearchState extends Equatable {
  const SearchState({
    required this.query,
    required this.repos,
    required this.page,
    required this.hasReachedMax,
  });

  const SearchState.initial()
    : query = '',
      repos = const [],
      page = 0,
      hasReachedMax = true;

  final String query;
  final List<GitHubRepo> repos;
  final int page;
  final bool hasReachedMax;

  SearchState copyWith({
    String? query,
    List<GitHubRepo>? repos,
    int? page,
    bool? hasReachedMax,
  }) {
    return SearchState(
      query: query ?? this.query,
      repos: repos ?? this.repos,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  bool get isEmpty => query.isNotEmpty && repos.isEmpty;

  @override
  List<Object?> get props => [query, repos, page, hasReachedMax];
}
