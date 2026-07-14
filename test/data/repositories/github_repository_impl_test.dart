import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:github_repo_explorer/data/local/favorite_repo_model.dart';
import 'package:github_repo_explorer/data/remote/github_api_exceptions.dart';
import 'package:github_repo_explorer/data/remote/github_repo_dto.dart';
import 'package:github_repo_explorer/data/remote/github_search_response_dto.dart';
import 'package:github_repo_explorer/data/repositories/github_repository_impl.dart';
import 'package:github_repo_explorer/domain/core/failure.dart';
import 'package:github_repo_explorer/domain/core/result.dart';
import 'package:github_repo_explorer/domain/entities/github_repo.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/mocks.dart';

void main() {
  late MockGitHubApiClient api;
  late MockFavoritesLocalDataSource local;
  late GitHubRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(FakeFavoriteRepoModel());
  });

  setUp(() {
    api = MockGitHubApiClient();
    local = MockFavoritesLocalDataSource();
    repository = GitHubRepositoryImpl(remote: api, local: local);
  });

  group('searchRepositories', () {
    test('maps a successful response to a list of entities', () async {
      when(() => api.searchRepositories(query: 'flutter', page: 1)).thenAnswer(
        (_) async => GitHubSearchReposResponseDto.fromJson({
          'total_count': 1,
          'items': [repoJson()],
        }),
      );

      final result = await repository.searchRepositories(
        query: 'flutter',
        page: 1,
      );

      final repos = (result as Success<List<GitHubRepo>>).value;
      expect(repos, hasLength(1));
      expect(repos.first.fullName, 'flutter/flutter');
    });

    test('maps a rate-limit exception to RateLimitFailure', () async {
      final resetAt = DateTime(2026, 1, 1, 12);
      when(() => api.searchRepositories(query: 'flutter', page: 1)).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/search/repositories'),
          error: RateLimitExceededException(resetAt: resetAt),
        ),
      );

      final result = await repository.searchRepositories(
        query: 'flutter',
        page: 1,
      );

      final failer = (result as Error<List<GitHubRepo>>).failure;
      expect(failer, isA<RateLimitFailure>());
      expect((failer as RateLimitFailure).resetAt, resetAt);
    });

    test('maps a no-connection exception to NetworkFailure', () async {
      when(() => api.searchRepositories(query: 'flutter', page: 1)).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/search/repositories'),
          error: const NoConnectionException(),
        ),
      );

      final result = await repository.searchRepositories(
        query: 'flutter',
        page: 1,
      );

      expect((result as Error).failure, isA<NetworkFailure>());
    });

    test('maps a blocked-request exception to ServerFailure', () async {
      when(() => api.searchRepositories(query: 'flutter', page: 1)).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/search/repositories'),
          error: const RequestBlockedException(),
        ),
      );

      final result = await repository.searchRepositories(
        query: 'flutter',
        page: 1,
      );

      expect((result as Error).failure, isA<ServerFailure>());
    });
  });

  group('getRepoDetail', () {
    test('combines repo + languages into one entity', () async {
      when(
        () => api.getRepo(owner: 'flutter', name: 'flutter'),
      ).thenAnswer((_) async => GitHubRepoDto.fromJson(repoJson()));

      when(
        () => api.getLanguages(owner: 'flutter', name: 'flutter'),
      ).thenAnswer((_) async => {'Dart': 900000});

      final result = await repository.getRepoDetail(
        owner: 'flutter',
        name: 'flutter',
      );

      expect((result as Success<GitHubRepo>).value.languages, {'Dart': 900000});
    });
  });

  group('toggleFavorite', () {
    test('adds the repo when it is not already a favorite', () async {
      when(() => local.contains(testRepo.id)).thenReturn(false);
      when(() => local.add(any())).thenAnswer((_) async {});

      final result = await repository.toggleFavorite(testRepo);

      expect(result, isA<Success<void>>());
      verify(() => local.add(any())).called(1);
    });

    test('removes the repo when it is already a favorite', () async {
      when(() => local.contains(testRepo.id)).thenReturn(true);
      when(() => local.remove(testRepo.id)).thenAnswer((_) async {});

      final result = await repository.toggleFavorite(testRepo);

      expect(result, isA<Success<void>>());
      verify(() => local.remove(testRepo.id)).called(1);
    });
  });

  group('getFavorites / isFavorite', () {
    test('getFavorites maps stored models back to entities', () {
      when(
        () => local.getAll(),
      ).thenReturn([FavoriteRepoModel.fromEntity(testRepo)]);

      final result = repository.getFavorites();
      expect(result, hasLength(1));
      expect(result.first.id, testRepo.id);
    });

    test('isFavorite delegates to the local data source', () {
      when(() => local.contains(testRepo.id)).thenReturn(true);
      expect(repository.isFavorite(testRepo.id), isTrue);
    });
  });
}
