import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../riverpod/favorites_notifier.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: favorites.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (failure, _) => Center(child: Text('$failure')),
        data: (repos) {
          if (repos.isEmpty) {
            return const Center(child: Text('No favorites saved yet.'));
          }
          return ListView.builder(
            itemCount: repos.length,
            itemBuilder: (context, index) {
              final repo = repos[index];
              return ListTile(
                title: Text(repo.fullName),
                subtitle: Text(
                  repo.description ?? 'No description',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.favorite),
                  onPressed: () =>
                      ref.read(favoritesNotifierProvider.notifier).toggle(repo),
                ),
                onTap: () =>
                    context.push('/repo/${repo.owner.login}/${repo.name}'),
              );
            },
          );
        },
      ),
    );
  }
}
