import 'package:hive_ce_flutter/hive_flutter.dart';

import 'favorite_repo_model.dart';

class FavoritesLocalDataSource {
  FavoritesLocalDataSource(this._box);

  static const boxName = 'favorites';

  final Box<FavoriteRepoModel> _box;

  static Future<FavoritesLocalDataSource> create() async {
    await Hive.initFlutter();
    Hive.registerAdapter(FavoriteRepoModelAdapter());
    final box = await Hive.openBox<FavoriteRepoModel>(boxName);
    return FavoritesLocalDataSource(box);
  }

  List<FavoriteRepoModel> getAll() => _box.values.toList();

  bool contains(int repoId) => _box.containsKey(repoId.toString());

  Future<void> add(FavoriteRepoModel model) {
    return _box.put(model.id.toString(), model);
  }

  Future<void> remove(int repoId) {
    return _box.delete(repoId.toString());
  }
}
