import '../../domain/entities/github_user.dart';

class GitHubUserDto {
  const GitHubUserDto({
    required this.id,
    required this.login,
    required this.avatarUrl,
    required this.htmlUrl,
  });

  factory GitHubUserDto.fromJson(Map<String, dynamic> json) {
    return GitHubUserDto(
      id: json['id'] as int,
      login: json['login'] as String,
      avatarUrl: json['avatar_url'] as String,
      htmlUrl: json['html_url'] as String,
    );
  }

  final int id;
  final String login;
  final String avatarUrl;
  final String htmlUrl;

  GitHubUser toEntity() {
    return GitHubUser(
      id: id,
      login: login,
      avatarUrl: avatarUrl,
      htmlUrl: htmlUrl,
    );
  }
}
