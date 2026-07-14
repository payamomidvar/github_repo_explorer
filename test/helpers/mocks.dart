import 'package:mocktail/mocktail.dart';

import 'package:github_repo_explorer/data/local/favorite_repo_model.dart';
import 'package:github_repo_explorer/data/local/favorites_local_data_source.dart';
import 'package:github_repo_explorer/data/remote/github_api_client.dart';
import 'package:github_repo_explorer/domain/repositories/github_repository.dart';

class MockGitHubApiClient extends Mock implements GitHubApiClient {}

class MockFavoritesLocalDataSource extends Mock
    implements FavoritesLocalDataSource {}

class MockGitHubRepository extends Mock implements GitHubRepository {}

class FakeFavoriteRepoModel extends Fake implements FavoriteRepoModel {}
