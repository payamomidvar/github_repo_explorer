import 'package:dio/dio.dart';

import 'github_api_exceptions.dart';
import 'github_repo_dto.dart';
import 'github_search_response_dto.dart';

const _githubToken = String.fromEnvironment('GITHUB_TOKEN');

class GitHubApiClient {
  GitHubApiClient({Dio? dio}) : _dio = dio ?? _buildDio();

  final Dio _dio;

  static Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.github.com',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    dio.interceptors.add(_GitHubInterceptor());
    return dio;
  }

  Future<GitHubSearchReposResponseDto> searchRepositories({
    required String query,
    required int page,
    int perPage = 20,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/search/repositories',
      queryParameters: {
        'q': query,
        'sort': 'stars',
        'order': 'desc',
        'per_page': perPage,
        'page': page,
      },
    );

    return GitHubSearchReposResponseDto.fromJson(response.data!);
  }

  Future<GitHubRepoDto> getRepo({
    required String owner,
    required String name,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/repos/$owner/$name',
    );
    return GitHubRepoDto.fromJson(response.data!);
  }

  Future<Map<String, int>> getLanguages({
    required String owner,
    required String name,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/repos/$owner/$name/languages',
    );
    return response.data!.map((key, value) => MapEntry(key, value as int));
  }
}

class _GitHubInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['User-Agent'] = 'github_repo_explorer-flutter-app';
    options.headers['Accept'] = 'application/vnd.github+json';
    if (_githubToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $_githubToken';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;

    if (response == null) {
      handler.next(err.copyWith(error: const NoConnectionException()));
      return;
    }

    if (response.statusCode == 403) {
      final remaining = response.headers.value('x-ratelimit-remaining');
      if (remaining == '0') {
        final resetHeader = response.headers.value('x-ratelimit-reset');
        final resetAt = resetHeader != null
            ? DateTime.fromMillisecondsSinceEpoch(int.parse(resetHeader) * 1000)
            : DateTime.now();
        handler.next(
          err.copyWith(error: RateLimitExceededException(resetAt: resetAt)),
        );
        return;
      }
      handler.next(err.copyWith(error: const RequestBlockedException()));
      return;
    }

    if (response.statusCode != null && response.statusCode! >= 500) {
      handler.next(
        err.copyWith(
          error: GitHubServerException(
            'GitHub server error (${response.statusCode}).',
          ),
        ),
      );
      return;
    }

    handler.next(err);
  }
}
