import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:github_repo_explorer/data/local/favorite_repo_model.dart';
import 'package:github_repo_explorer/data/remote/github_repo_dto.dart';
import 'package:github_repo_explorer/data/remote/github_search_response_dto.dart';
import 'package:github_repo_explorer/main.dart';
import 'package:github_repo_explorer/presentation/riverpod/providers.dart';

import '../helpers/fixtures.dart';
import '../helpers/mocks.dart';

void main() {
  late MockGitHubApiClient api;
  late MockFavoritesLocalDataSource local;

  setUpAll(() {
    registerFallbackValue(FakeFavoriteRepoModel());
  });

  setUp(() {
    api = MockGitHubApiClient();
    local = MockFavoritesLocalDataSource();

    when(
      () => api.searchRepositories(query: any(named: 'query'), page: 1),
    ).thenAnswer(
      (_) async => GitHubSearchReposResponseDto.fromJson({
        'total_count': 1,
        'items': [repoJson()],
      }),
    );
    when(
      () => api.getRepo(owner: 'flutter', name: 'flutter'),
    ).thenAnswer((_) async => GitHubRepoDto.fromJson(repoJson()));
    when(
      () => api.getLanguages(owner: 'flutter', name: 'flutter'),
    ).thenAnswer((_) async => {'Dart': 900000});
    when(() => local.contains(any())).thenReturn(false);
    when(() => local.add(any())).thenAnswer((_) async {});
    when(() => local.getAll()).thenReturn([]);
  });

  testWidgets('search -> detail -> favorite updates the Favorites screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          githubApiClientProvider.overrideWithValue(api),
          favoritesLocalDataSourceProvider.overrideWithValue(local),
        ],
        child: const GithubExplorerApp(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Search.
    await tester.enterText(find.byType(TextField), 'flutter');
    await tester.pump(const Duration(milliseconds: 400)); // past the debounce
    await tester.pumpAndSettle();

    expect(find.text('flutter/flutter'), findsOneWidget);

    // 2. Open the detail screen.
    await tester.tap(find.text('flutter/flutter'));
    await tester.pumpAndSettle();

    expect(find.text('Dart'), findsOneWidget);

    // 3. Save it as a favorite.
    when(
      () => local.getAll(),
    ).thenReturn([FavoriteRepoModel.fromEntity(testRepo)]);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    verify(() => local.add(any())).called(1);
    when(() => local.contains(any())).thenReturn(true);
    
    // 4. Confirm it shows up on the Favorites screen.
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.favorite));
    await tester.pumpAndSettle();

    expect(find.text('flutter/flutter'), findsOneWidget);
  });
}
