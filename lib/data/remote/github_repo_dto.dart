import '../../domain/entities/github_repo.dart';
import 'github_user_dto.dart';

class GitHubRepoDto {
  const GitHubRepoDto({
    required this.id,
    required this.name,
    required this.fullName,
    required this.owner,
    required this.description,
    required this.stargazersCount,
    required this.openIssuesCount,
    required this.htmlUrl,
  });

  factory GitHubRepoDto.fromJson(Map<String, dynamic> json) {
    return GitHubRepoDto(
      id: json['id'] as int,
      name: json['name'] as String,
      fullName: json['full_name'] as String,
      owner: GitHubUserDto.fromJson(json['owner'] as Map<String, dynamic>),
      description: json['description'] as String?,
      stargazersCount: json['stargazers_count'] as int,
      openIssuesCount: json['open_issues_count'] as int,
      htmlUrl: json['html_url'] as String,
    );
  }

  final int id;
  final String name;
  final String fullName;
  final GitHubUserDto owner;
  final String? description;
  final int stargazersCount;
  final int openIssuesCount;
  final String htmlUrl;

  GitHubRepo toEntity({Map<String, int>? languages}) {
    return GitHubRepo(
      id: id,
      name: name,
      fullName: fullName,
      owner: owner.toEntity(),
      description: description,
      stargazersCount: stargazersCount,
      openIssuesCount: openIssuesCount,
      htmlUrl: htmlUrl,
      languages: languages,
    );
  }
}
