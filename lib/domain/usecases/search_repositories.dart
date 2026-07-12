import '../core/result.dart';
import '../entities/github_repo.dart';
import '../repositories/github_repository.dart';

class SearchRepositories {
  const SearchRepositories(this._repository);

  final GitHubRepository _repository;

  Future<Result<List<GitHubRepo>>> call({
    required String query,
    required int page,
  }) {
    return _repository.searchRepositories(query: query, page: page);
  }
}
