import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:github_repo_explorer/domain/core/result.dart';
import 'package:github_repo_explorer/domain/usecases/toggle_favorite.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/mocks.dart';

void main() {
  test('delegates to repository.toggleFavorite with the given repo', () async {
    final repository = MockGitHubRepository();
    final usecase = ToggleFavorite(repository);

    when(
      () => repository.toggleFavorite(testRepo),
    ).thenAnswer((_) async => const Success(null));

    final result = await usecase(testRepo);

    expect(result, isA<Success<void>>());
    verify(() => repository.toggleFavorite(testRepo)).called(1);
  });
}
