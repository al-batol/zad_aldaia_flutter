import 'package:drift/drift.dart';
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
    Map<String, List<String>> map = {};

    await (_db.selectOnly(_db.articleItems, distinct: true)
          ..addColumns([_db.articleItems.article, _db.articleItems.category])
          ..where(
            _db.articleItems.section.equals(section) &
                _db.articleItems.language.equals(language),
          ))
        .map((row) {
          var category = row.read(_db.articleItems.category)!;
          var article = row.read(_db.articleItems.article)!;
          map.putIfAbsent(category, () => <String>[]);
          map[category]!.add(article);
        })
        .get();

    return map.entries
        .map((e) => Category(title: e.key, articles: e.value))
        .toList();
  }*/

  List<Category> categories = [];

  Future<List<Category>> getCategories(String section, String language) async {
    final response = await _supabase
        .from('categories')
        .select('''*, articles (*)''')
        .eq('section', section)
        .eq('lang', language)
        .order('order', ascending: true);
    final categories =
        response.map<Category>((item) => Category.fromJson(item)).toList();
    return categories;
  }

  Future<bool> swapCategoriesOrder(String id1, String id2) async {
    try {
      final response = await _supabase
          .from('categories')
          .select('id, order')
          .or('id.eq.$id1,id.eq.$id2');

      if (response.length != 2) {
        print('❌ One or both IDs not found.');
        return false;
      }

      final order1 = response.firstWhere((item) => item['id'] == id1)['order'];
      print('order1: $order1');
      final order2 = response.firstWhere((item) => item['id'] == id2)['order'];
      print('order2: $order2');

      await _supabase
          .from('categories')
          .update({'order': order2})
          .eq('id', id1);
      await _supabase
          .from('categories')
          .update({'order': order1})
          .eq('id', id2);

      print('✅ Orders swapped between ID $id1 and ID $id2');
      return true;
    } catch (e) {
      print('Error swapping article item orders: $e');
      return false;
    }
  }

  /*List<Article> articles = <Article>[];
  Future<List<Article>> getArticles(String section, String language) async {
    await _supabase
        .from('articles')
        .select()
        .eq('section', section)
        .eq('lang', language)
        .select()
        .then((value) {
          articles =
              value.map<Article>((item) => Article.fromJson(item)).toList();
        });
    print('articles ${articles.map((e) => e.title).toList()}');
    return articles;
  }*/
}
