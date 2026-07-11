import 'package:equatable/equatable.dart';

import 'github_user.dart';

class GitHubRepo extends Equatable {
  const GitHubRepo({
    required this.id,
    required this.name,
    required this.fullName,
    required this.owner,
    required this.description,
    required this.stargazersCount,
    required this.openIssuesCount,
    required this.htmlUrl,
    this.languages,
  });

  final int id;
  final String name;
  final String fullName;
  final GitHubUser owner;
  final String? description;
  final int stargazersCount;
  final int openIssuesCount;
  final String htmlUrl;
  final Map<String, int>? languages;

  @override
  List<Object?> get props => [
    id,
    name,
    fullName,
    owner,
    description,
    stargazersCount,
    openIssuesCount,
    htmlUrl,
    languages,
  ];
}
