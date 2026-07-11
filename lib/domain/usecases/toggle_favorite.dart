import '../entities/github_repo.dart';
import '../repositories/github_repository.dart';
import '../core/result.dart';

class ToggleFavorite {
  ToggleFavorite(this._repository);

  final GithubRepository _repository;

  Future<Result<void>> call(GitHubRepo repo) {
    return _repository.toggleFavorite(repo);
  }
}
