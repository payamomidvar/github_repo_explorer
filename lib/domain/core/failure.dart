import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

class RateLimitFailure extends Failure {
  const RateLimitFailure({required this.resetAt})
    : super('GitHub API rate limit exceeded.');

  final DateTime resetAt;
  @override
  List<Object?> get props => [message, resetAt];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}
