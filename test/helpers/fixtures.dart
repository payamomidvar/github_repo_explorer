import 'package:github_repo_explorer/domain/entities/github_repo.dart';
import 'package:github_repo_explorer/domain/entities/github_user.dart';

const testOwner = GitHubUser(
  id: 1,
  login: 'flutter',
  avatarUrl: 'https://avatars.example.com/flutter.png',
  htmlUrl: 'https://github.com/flutter',
);

const testRepo = GitHubRepo(
  id: 100,
  name: 'flutter',
  fullName: 'flutter/flutter',
  owner: testOwner,
  description: "Google's UI toolkit.",
  stargazersCount: 12345,
  openIssuesCount: 42,
  htmlUrl: 'https://github.com/flutter/flutter',
  languages: {'Dart': 900000, 'C++': 50000},
);

Map<String, dynamic> repoJson({String? description = "Google's UI toolkit."}) =>
    {
      'id': 100,
      'name': 'flutter',
      'full_name': 'flutter/flutter',
      'description': description,
      'stargazers_count': 12345,
      'open_issues_count': 42,
      'html_url': 'https://github.com/flutter/flutter',
      'owner': {
        'id': 1,
        'login': 'flutter',
        'avatar_url': 'https://avatars.example.com/flutter.png',
        'html_url': 'https://github.com/flutter',
      },
    };
