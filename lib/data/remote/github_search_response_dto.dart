import 'github_repo_dto.dart';

class GitHubSearchReposResponseDto {
  const GitHubSearchReposResponseDto({
    required this.totalCount,
    required this.items,
  });

  factory GitHubSearchReposResponseDto.fromJson(Map<String, dynamic> json) {
    return GitHubSearchReposResponseDto(
      totalCount: json['total_count'] as int,
      items: (json['items'] as List<dynamic>)
          .map((item) => GitHubRepoDto.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  final int totalCount;
  final List<GitHubRepoDto> items;
}
