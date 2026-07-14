import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:github_repo_explorer/domain/core/failure.dart';
import 'package:github_repo_explorer/presentation/riverpod/search_notifier.dart';
import 'package:github_repo_explorer/presentation/riverpod/search_state.dart';
import 'package:github_repo_explorer/presentation/screens/search_screen.dart';

import '../../helpers/fixtures.dart';

class _FixedSearchNotifier extends SearchNotifier {
  _FixedSearchNotifier(this._build);
  final Future<SearchState> Function() _build;

  @override
  Future<SearchState> build() => _build();
}

Widget _wrap(Future<SearchState> Function() build) {
  return ProviderScope(
    overrides: [
      searchNotifierProvider.overrideWith(() => _FixedSearchNotifier(build)),
    ],
    child: const MaterialApp(home: SearchScreen()),
  );
}

void main() {
  testWidgets('shows a spinner while loading', (tester) async {
    await tester.pumpWidget(_wrap(() => Completer<SearchState>().future));

    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows the results list on success', (tester) async {
    await tester.pumpWidget(
      _wrap(
        () async => const SearchState(
          query: 'flutter',
          repos: [testRepo],
          page: 1,
          hasReachedMax: true,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('flutter/flutter'), findsOneWidget);
  });

  testWidgets('shows the empty state when a search yields no results', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        () async => const SearchState(
          query: 'zzzzz-no-match',
          repos: [],
          page: 1,
          hasReachedMax: true,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('No repositories found.'), findsOneWidget);
  });

  testWidgets('shows a rate-limited message', (tester) async {
    final resetAt = DateTime.now().add(const Duration(minutes: 30));
    await tester.pumpWidget(
      _wrap(() async => throw RateLimitFailure(resetAt: resetAt)),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Rate limit exceeded'), findsOneWidget);
  });

  testWidgets('shows an offline message', (tester) async {
    await tester.pumpWidget(_wrap(() async => throw const NetworkFailure()));
    await tester.pumpAndSettle();

    expect(find.text('No internet connection.'), findsOneWidget);
  });
}
