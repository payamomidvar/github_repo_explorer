sealed class GitHubApiExceptions implements Exception {
  const GitHubApiExceptions(this.message);
  final String message;
}

class RateLimitExceededException extends GitHubApiExceptions {
  const RateLimitExceededException({required this.resetAt})
    : super('GitHub API rate limit exceeded.');
  final DateTime resetAt;
}

class RequestBlockedException extends GitHubApiExceptions {
  const RequestBlockedException()
    : super('Request blocked by GitHub (abuse detection).');
}

class GitHubServerException extends GitHubApiExceptions {
  const GitHubServerException(super.message);
}

class NoConnectionException extends GitHubApiExceptions {
  const NoConnectionException() : super('No internet connection.');
}
