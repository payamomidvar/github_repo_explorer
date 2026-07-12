import '../core/result.dart';
import '../entities/github_repo.dart';

abstract class GitHubRepository {
  Future<Result<List<GitHubRepo>>> searchRepositories({
    required String query,
    required int page,
  });

  Future<Result<GitHubRepo>> getRepoDetail({
    required String owner,
    required String name,
  });

  Future<Result<void>> toggleFavorite(GitHubRepo repo);

  List<GitHubRepo> getFavorites();

  bool isFavorite(int repoId);
}
