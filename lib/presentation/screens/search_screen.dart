import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/core/failure.dart';
import '../riverpod/search_notifier.dart';
import '../riverpod/search_state.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(searchNotifierProvider.notifier).search(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('GitHub Repo Explorer'),
        actions: [
          IconButton(
            onPressed: () => context.push('/favorites'),
            icon: Icon(Icons.favorite),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _controller,
              onChanged: _onQueryChanged,
              decoration: const InputDecoration(
                hintText: 'Search repositories...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(child: _buildBody(searchState)),
        ],
      ),
    );
  }

  Widget _buildBody(AsyncValue<SearchState> searchState) {
    return searchState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (failure, _) => _SearchErrorView(failure: failure as Failure),
      data: (state) {
        if (state.query.isEmpty) {
          return const Center(
            child: Text('Type to search GitHub repositories.'),
          );
        }
        
        if (state.isEmpty) {
          return const Center(child: Text('No repositories found.'));
        }

        return ListView.builder(
          itemCount: state.repos.length,
          itemBuilder: (context, index) {
            if (!state.hasReachedMax && index == state.repos.length - 3) {
              ref.read(searchNotifierProvider.notifier).loadNextPage();
            }
            final repo = state.repos[index];
            return ListTile(
              title: Text(repo.fullName),
              subtitle: Text(
                repo.description ?? 'No description',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, size: 16),
                  const SizedBox(width: 4),
                  Text('${repo.stargazersCount}'),
                ],
              ),
              onTap: () =>
                  context.push('/repo/${repo.owner.login}/${repo.name}'),
            );
          },
        );
      },
    );
  }
}

class _SearchErrorView extends StatelessWidget {
  const _SearchErrorView({required this.failure});

  final Failure failure;

  @override
  Widget build(BuildContext context) {
    return switch (failure) {
      RateLimitFailure(:final resetAt) => _Message(
        icon: Icons.hourglass_bottom,
        text:
            'Rate limit exceeded.\n'
            'Try again at ${TimeOfDay.fromDateTime(resetAt).format(context)}.',
      ),
      NetworkFailure() => const _Message(
        icon: Icons.wifi_off,
        text: 'No internet connection.',
      ),
      _ => _Message(icon: Icons.error_outline, text: failure.message),
    };
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 12),
            Text(text, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
