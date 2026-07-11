import 'package:equatable/equatable.dart';

class GitHubUser extends Equatable {
  const GitHubUser({
    required this.id,
    required this.login,
    required this.avatarUrl,
    required this.htmlUrl,
  });

  final int id;
  final String login;
  final String avatarUrl;
  final String htmlUrl;

  @override
  List<Object?> get props => [id, login, avatarUrl, htmlUrl];
}
