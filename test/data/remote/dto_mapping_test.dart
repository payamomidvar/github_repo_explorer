import 'package:flutter_test/flutter_test.dart';

import 'package:github_repo_explorer/data/remote/github_repo_dto.dart';
import 'package:github_repo_explorer/data/remote/github_user_dto.dart';

import '../../helpers/fixtures.dart';

void main() {
  group('GitHubUserDto', () {
    test("fromJson reads GitHub's actual snake_case fields", () {
      final dto = GitHubUserDto.fromJson({
        'id': 1,
        'login': 'flutter',
        'avatar_url': 'https://avatars.example.com/flutter.png',
        'html_url': 'https://github.com/flutter',
      });

      expect(dto.avatarUrl, 'https://avatars.example.com/flutter.png');
      expect(dto.htmlUrl, 'https://github.com/flutter');
    });

    test('toEntity maps every field 1:1', () {
      final dto = GitHubUserDto.fromJson({
        'id': 1,
        'login': 'flutter',
        'avatar_url': 'a',
        'html_url': 'h',
      });

      final entity = dto.toEntity();

      expect(entity.id, dto.id);
      expect(entity.login, dto.login);
      expect(entity.avatarUrl, dto.avatarUrl);
      expect(entity.htmlUrl, dto.htmlUrl);
    });
  });

  
  group('GitHubRepoDto', () {
    test('fromJson parses nested owner and description', () {
      final dto = GitHubRepoDto.fromJson(repoJson());

      expect(dto.fullName, 'flutter/flutter');
      expect(dto.owner.login, 'flutter');
    });

    test('fromJson handles a null description', () {
      final dto = GitHubRepoDto.fromJson(repoJson(description: null));
      expect(dto.description, isNull);
    });

    test('toEntity carries the languages passed in separately', () {
      final dto = GitHubRepoDto.fromJson(repoJson());
      final entity = dto.toEntity(languages: {'Dart': 1});

      expect(entity.languages, {'Dart': 1});
      expect(entity.owner.login, dto.owner.login);
    });

    test('toEntity leaves languages null when not provided', () {
      expect(GitHubRepoDto.fromJson(repoJson()).toEntity().languages, isNull);
    });
  });
}
