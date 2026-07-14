import 'dart:nativewrappers/_internal/vm/lib/ffi_allocation_patch.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:github_repo_explorer/domain/core/result.dart';
import 'package:github_repo_explorer/domain/entities/github_repo.dart';
import 'package:github_repo_explorer/domain/usecases/get_repo_detail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/mocks.dart';

void main() {
  test('delegates to repository.getRepoDetail with owner/name', () async {
    final repository = MockGitHubRepository();
    final usecase = GetRepoDetail(repository);

    when(
      () => repository.getRepoDetail(owner: 'flutter', name: 'flutter'),
    ).thenAnswer((_) async => const Success(testRepo));

    final result = await usecase(owner: 'flutter', name: 'flutter');

    expect(result, isA<Success<GitHubRepo>>());
    verify(
      () => repository.getRepoDetail(owner: 'flutter', name: 'flutter'),
    ).call(1);
  });
}
