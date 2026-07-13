import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/repo_detail_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/search_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/search',
    routes: [
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/repo/:owner/:name',
        builder: (context, state) => RepoDetailScreen(
          owner: state.pathParameters['owner']!,
          name: state.pathParameters['name']!,
        ),
      ),
      GoRoute(
        path: '/favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),
    ],
  );
});
