import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:github_repo_explorer/domain/core/failure.dart';
import 'package:github_repo_explorer/domain/core/result.dart';
import 'package:github_repo_explorer/domain/entities/github_repo.dart';
import 'package:github_repo_explorer/domain/usecases/search_repositories.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/mocks.dart';

void main() {
  late MockGitHubRepository repository;
  late SearchRepositories usecase;

  setUp(() {
    repository = MockGitHubRepository();
    usecase = SearchRepositories(repository);
  });

  test(
    'delegates to repository.searchRepositories with the same args',
    () async {
      when(
        () => repository.searchRepositories(query: 'flutter', page: 1),
      ).thenAnswer((_) async => const Success([testRepo]));

      final result = await usecase(query: 'flutter', page: 1);

      expect(result, isA<Success<List<GitHubRepo>>>());
      verify(
        () => repository.searchRepositories(query: 'flutter', page: 1),
      ).called(1);
    },
  );

  test('propagates a Failure unchanged', () async {
    when(
      () => repository.searchRepositories(query: 'flutter', page: 1),
    ).thenAnswer((_) async => const Error(NetworkFailure()));

    final result = await usecase(query: 'flutter', page: 1);

    expect((result as Error).failure, isA<NetworkFailure>());
  });
}
