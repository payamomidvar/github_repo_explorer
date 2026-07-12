import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/github_repo.dart';
import '../../domain/usecases/toggle_favorite.dart';
import 'providers.dart';

class FavoritesNotifier extends AsyncNotifier<List<GitHubRepo>> {
  late final ToggleFavorite _toggleFavorite;

  @override
  Future<List<GitHubRepo>> build() {
    _toggleFavorite = ref.read(toggleFavoriteProvider);
    return Future.value(ref.read(githubRepositoryProvider).getFavorites());
  }

  Future<void> toggle(GitHubRepo repo) async {
    final result = await _toggleFavorite(repo);
    state = result.when(
      success: (value) =>
          AsyncData(ref.read(githubRepositoryProvider).getFavorites()),
      error: (failure) => AsyncError(failure, StackTrace.current),
    );
  }

  bool isFavorite(int repoId) {
    return ref.read(githubRepositoryProvider).isFavorite(repoId);
  }
}

final favoritesNotifierProvider =
    AsyncNotifierProvider<FavoritesNotifier, List<GitHubRepo>>(
      FavoritesNotifier.new,
    );