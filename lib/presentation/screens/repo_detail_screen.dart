import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/core/failure.dart';
import '../../domain/entities/github_repo.dart';
import '../riverpod/favorites_notifier.dart';
import '../riverpod/providers.dart';

final repoDetailProvider = FutureProvider.autoDispose
    .family<GitHubRepo, ({String owner, String name})>((ref, args) async {
      final getRepoDetail = ref.watch(getRepoDetailProvider);
      final result = await getRepoDetail(owner: args.owner, name: args.name);
      return result.when(
        success: (repo) => repo,
        error: (failure) => throw failure,
      );
    });

class RepoDetailScreen extends ConsumerWidget {
  const RepoDetailScreen({required this.owner, required this.name, super.key});

  final String owner;
  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(repoDetailProvider((owner: owner, name: name)));

    return Scaffold(
      appBar: AppBar(title: Text('$owner/$name')),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (failure, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              failure is Failure ? failure.message : 'Something went wrong.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (repo) => _RepoDetailBody(repo: repo),
      ),
    );
  }
}

class _RepoDetailBody extends ConsumerWidget {
  const _RepoDetailBody({required this.repo});

  final GitHubRepo repo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritesNotifierProvider);
    final isFavorite =
        favoritesAsync.value?.any((f) => f.id == repo.id) ?? false;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(repo.fullName, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(repo.description ?? 'No description provided.'),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.star, size: 18),
            const SizedBox(width: 4),
            Text('${repo.stargazersCount} stars'),
            const SizedBox(width: 16),
            const Icon(Icons.error_outline, size: 18),
            const SizedBox(width: 4),
            Text('${repo.openIssuesCount} open issues'),
          ],
        ),
        const SizedBox(height: 24),
        Text('Languages', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: (repo.languages ?? const {}).keys
              .map((language) => Chip(label: Text(language)))
              .toList(),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () =>
              ref.read(favoritesNotifierProvider.notifier).toggle(repo),
          icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
          label: Text(isFavorite ? 'Saved' : 'Save'),
        ),
      ],
    );
  }
}
