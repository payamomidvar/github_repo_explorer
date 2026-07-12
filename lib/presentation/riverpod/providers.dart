import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/favorites_local_data_source.dart';
import '../../data/remote/github_api_client.dart';
import '../../data/repositories/github_repository_impl.dart';
import '../../domain/repositories/github_repository.dart';
import '../../domain/usecases/get_repo_detail.dart';
import '../../domain/usecases/search_repositories.dart';
import '../../domain/usecases/toggle_favorite.dart';

final githubApiClientProvider = Provider<GitHubApiClient>((ref) {
  return GitHubApiClient();
});

final favoritesLocalDataSourceProvider = Provider<FavoritesLocalDataSource>((
  ref,
) {
  throw UnimplementedError(
    'favoritesLocalDataSourceProvider must be overridden in main().',
  );
});

final githubRepositoryProvider = Provider<GitHubRepository>((ref) {
  return GitHubRepositoryImpl(
    remote: ref.watch(githubApiClientProvider),
    local: ref.watch(favoritesLocalDataSourceProvider),
  );
});

final searchRepositoriesProvider = Provider<SearchRepositories>((ref) {
  return SearchRepositories(ref.watch(githubRepositoryProvider));
});

final getRepoDetailProvider = Provider<GetRepoDetail>((ref) {
  return GetRepoDetail(ref.watch(githubRepositoryProvider));
});


final toggleFavoriteProvider = Provider<ToggleFavorite>((ref) {
  return ToggleFavorite(ref.watch(githubRepositoryProvider));
});
