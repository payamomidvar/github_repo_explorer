import 'package:hive_ce/hive.dart';

import '../../domain/entities/github_repo.dart';
import '../../domain/entities/github_user.dart';

class FavoriteRepoModel {
  const FavoriteRepoModel({
    required this.id,
    required this.name,
    required this.fullName,
    required this.description,
    required this.stargazersCount,
    required this.openIssuesCount,
    required this.htmlUrl,
    required this.ownerId,
    required this.ownerLogin,
    required this.ownerAvatarUrl,
    required this.ownerHtmlUrl,
  });

  factory FavoriteRepoModel.fromEntity(GitHubRepo repo) {
    return FavoriteRepoModel(
      id: repo.id,
      name: repo.name,
      fullName: repo.fullName,
      description: repo.description,
      stargazersCount: repo.stargazersCount,
      openIssuesCount: repo.openIssuesCount,
      htmlUrl: repo.htmlUrl,
      ownerId: repo.owner.id,
      ownerLogin: repo.owner.login,
      ownerAvatarUrl: repo.owner.avatarUrl,
      ownerHtmlUrl: repo.owner.htmlUrl,
    );
  }

  final int id;
  final String name;
  final String fullName;
  final String? description;
  final int stargazersCount;
  final int openIssuesCount;
  final String htmlUrl;
  final int ownerId;
  final String ownerLogin;
  final String ownerAvatarUrl;
  final String ownerHtmlUrl;

  GitHubRepo toEntity() {
    return GitHubRepo(
      id: id,
      name: name,
      fullName: fullName,
      owner: GitHubUser(
        id: ownerId,
        login: ownerLogin,
        avatarUrl: ownerAvatarUrl,
        htmlUrl: ownerHtmlUrl,
      ),
      description: description,
      stargazersCount: stargazersCount,
      openIssuesCount: openIssuesCount,
      htmlUrl: htmlUrl,
    );
  }
}

class FavoriteRepoModelAdapter extends TypeAdapter<FavoriteRepoModel> {
  @override
  final int typeId = 0;

  @override
  FavoriteRepoModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return FavoriteRepoModel(
      id: fields[0] as int,
      name: fields[1] as String,
      fullName: fields[2] as String,
      description: fields[3] as String?,
      stargazersCount: fields[4] as int,
      openIssuesCount: fields[5] as int,
      htmlUrl: fields[6] as String,
      ownerId: fields[7] as int,
      ownerLogin: fields[8] as String,
      ownerAvatarUrl: fields[9] as String,
      ownerHtmlUrl: fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteRepoModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.fullName)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.stargazersCount)
      ..writeByte(5)
      ..write(obj.openIssuesCount)
      ..writeByte(6)
      ..write(obj.htmlUrl)
      ..writeByte(7)
      ..write(obj.ownerId)
      ..writeByte(8)
      ..write(obj.ownerLogin)
      ..writeByte(9)
      ..write(obj.ownerAvatarUrl)
      ..writeByte(10)
      ..write(obj.ownerHtmlUrl);
  }
}
