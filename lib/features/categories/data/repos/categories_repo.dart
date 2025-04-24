import 'package:drift/drift.dart';
import 'package:zad_aldaia/core/database/my_database.dart';
import 'package:zad_aldaia/features/categories/data/models/category.dart';

class CategoriesRepo {
  final MyDatabase _db;

  CategoriesRepo(this._db);

  Future<List<Category>> getSectionCategories(String section, String language) async{
    Map<String, List<String>> map = {};

    await (_db.selectOnly(_db.articleItems, distinct: true)
          ..addColumns([_db.articleItems.article, _db.articleItems.category])
          ..where(_db.articleItems.section.equals(section) & _db.articleItems.language.equals(language)))
        .map((row) {
          var category = row.read(_db.articleItems.category)!;
          var article = row.read(_db.articleItems.article)!;
          map.putIfAbsent(category, () => <String>[]);
          map[category]!.add(article);
        })
        .get();

   return map.entries.map((e) => Category(title: e.key, articles: e.value)).toList();
  }
}
