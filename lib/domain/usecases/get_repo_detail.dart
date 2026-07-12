import '../core/result.dart';
import '../entities/github_repo.dart';
import '../repositories/github_repository.dart';

class GetRepoDetail {
  const GetRepoDetail(this._repository);

  final GitHubRepository _repository;

  Future<Result<GitHubRepo>> call({
    required String owner,
    required String name,
  }) {
    return _repository.getRepoDetail(owner: owner, name: name);
  }
}
