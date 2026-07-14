import 'package:dio/dio.dart';

import '../../domain/core/failure.dart';
import '../../domain/core/result.dart';
import '../../domain/entities/github_repo.dart';
import '../../domain/repositories/github_repository.dart';
import '../local/favorite_repo_model.dart';
import '../local/favorites_local_data_source.dart';
import '../remote/github_api_client.dart';
import '../remote/github_api_exceptions.dart';

class GitHubRepositoryImpl implements GitHubRepository {
  GitHubRepositoryImpl({
    required GitHubApiClient remote,
    required FavoritesLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  final GitHubApiClient _remote;
  final FavoritesLocalDataSource _local;

  @override
  List<GitHubRepo> getFavorites() {
    return _local.getAll().map((model) => model.toEntity()).toList();
  }

  @override
  Future<Result<GitHubRepo>> getRepoDetail({
    required String owner,
    required String name,
  }) async {
    try {
      final repoDto = await _remote.getRepo(owner: owner, name: name);
      final languages = await _remote.getLanguages(owner: owner, name: name);
      return Success(repoDto.toEntity(languages: languages));
    } catch (error) {
      return Error(_mapError(error));
    }
  }

  @override
  bool isFavorite(int repoId) => _local.contains(repoId);

  @override
  Future<Result<List<GitHubRepo>>> searchRepositories({
    required String query,
    required int page,
  }) async {
    try {
      final response = await _remote.searchRepositories(
        query: query,
        page: page,
      );
      final repos = response.items.map((dto) => dto.toEntity()).toList();
      return Success(repos);
    } catch (error) {
      return Error(_mapError(error));
    }
  }

  @override
  Future<Result<void>> toggleFavorite(GitHubRepo repo) async {
    try {
      if (_local.contains(repo.id)) {
        await _local.remove(repo.id);
      } else {
        await _local.add(FavoriteRepoModel.fromEntity(repo));
      }
      return const Success(null);
    } catch (error) {
      return Error(CacheFailure(error.toString()));
    }
  }

  Failure _mapError(Object error) {
    if (error is DioException && error.error is GitHubApiExceptions) {
      final apiError = error.error! as GitHubApiExceptions;

      return switch (apiError) {
        RateLimitExceededException() => RateLimitFailure(
          resetAt: apiError.resetAt,
        ),
        RequestBlockedException() => ServerFailure(apiError.message),
        GitHubServerException() => ServerFailure(apiError.message),
        NoConnectionException() => const NetworkFailure(),
      };
    }
    return ServerFailure(error.toString());
  }
}
