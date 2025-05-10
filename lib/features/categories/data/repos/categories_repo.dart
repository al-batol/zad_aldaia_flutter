import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zad_aldaia/core/database/my_database.dart';
import 'package:zad_aldaia/features/categories/data/models/category.dart';

class CategoriesRepo {
  final MyDatabase _db;

  final SupabaseClient _supabase;

  CategoriesRepo(this._db, this._supabase);

  /*Future<List<Category>> getSectionCategories(
    String section,
    String language,
  ) async {
    Map<String, List<Article>> map = {};

    await (_db.selectOnly(_db.articleItems, distinct: true)
          ..addColumns([
            _db.articleItems.id,
            _db.articleItems.article,
            _db.articleItems.category,
          ])
          ..where(
            _db.articleItems.section.equals(section) &
                _db.articleItems.language.equals(language),
          ))
        .map((row) {
          var category = row.read(_db.articleItems.category)!;
          var article = row.read(_db.articleItems.article)!;
          var id = row.read(_db.articleItems.id)!;
          map.putIfAbsent(category, () => <Article>[]);
          map[category]!.add(
            Article(
              id: id,
              title: article,
              category: category,
              section: section,
              lang: language,
            ),
          );
        })
        .get();

    return map.entries
        .map((e) => Category(title: e.key, articles: e.value))
        .toList();
  }*/

  Future<List<Category>> getCategoriesFromSupabase(
    String section,
    String language,
  ) async {
    try {
      final result = await _supabase
          .from('categories')
          .select()
          .eq('section', section)
          /*.eq('language', language)*/
          .order('order', ascending: false);
      print(result);
      return result.map((data) => Category.fromJson(data)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> reOderCategories(String id, int newIndex) async {
    try {
      await _supabase.rpc(
        'reoderSectionCategories',
        params: {'p_category_id': id, 'p_category_order': newIndex},
      );
      print('✅ Reordering completed successfully');
      return true;
    } catch (e) {
      print('❌ Error reordering categories: $e');
      return false;
    }
  }
}
