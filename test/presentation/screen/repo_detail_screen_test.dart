import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:github_repo_explorer/domain/entities/github_repo.dart';
import 'package:github_repo_explorer/presentation/riverpod/favorites_notifier.dart';
import 'package:github_repo_explorer/presentation/screens/repo_detail_screen.dart';

import '../../helpers/fixtures.dart';

class _FixedFavoritesNotifier extends FavoritesNotifier {
  _FixedFavoritesNotifier(this._initial);
  final List<GitHubRepo> _initial;
  final List<GitHubRepo> toggled = [];

  @override
  Future<List<GitHubRepo>> build() async => _initial;

  @override
  Future<void> toggle(GitHubRepo repo) async {
    toggled.add(repo);
    state = AsyncData([..._initial, repo]);
  }
}

void main() {
  testWidgets('shows repo details and toggles favorite on tap', (tester) async {
    final fakeFavorites = _FixedFavoritesNotifier(const []);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          repoDetailProvider((
            owner: 'flutter',
            name: 'flutter-repo',
          )).overrideWith((ref) async => testRepo),
          favoritesNotifierProvider.overrideWith(() => fakeFavorites),
        ],
        child: const MaterialApp(
          home: RepoDetailScreen(owner: 'flutter', name: 'flutter-repo'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('flutter/flutter'), findsOneWidget);
    expect(find.text('Dart'), findsOneWidget);
    expect(find.text('42 open issues'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(fakeFavorites.toggled, [testRepo]);
    expect(find.text('Saved'), findsOneWidget);
  });
}
