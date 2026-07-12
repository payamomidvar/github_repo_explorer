import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/local/favorites_local_data_source.dart';
import 'presentation/riverpod/providers.dart';

import 'presentation/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final favoritesLocalDataSource = await FavoritesLocalDataSource.create();

  runApp(
     ProviderScope(
      overrides: [
        favoritesLocalDataSourceProvider.overrideWithValue(
          favoritesLocalDataSource,
        ),
      ],
      child: GithubExplorerApp(),
    ),
  );
}

class GithubExplorerApp extends ConsumerWidget {
  const GithubExplorerApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'GitHub Repo Explorer',
      theme: ThemeData(useMaterial3: true, brightness: Brightness.light),
      darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
