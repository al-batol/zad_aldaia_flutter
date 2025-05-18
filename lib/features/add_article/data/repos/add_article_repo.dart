import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zad_aldaia/core/database/my_database.dart';
import 'package:zad_aldaia/features/add_article/data/models/article.dart';
import 'package:zad_aldaia/features/add_category/data/models/firestore_category.dart';

class AddArticleRepo {
  final MyDatabase _dp;
  final SupabaseClient _supabase;
  AddArticleRepo(this._dp, this._supabase);

  Future<List<FireStoreCategory>> getCategoriesList() async {
    try {
      final result = await _supabase.from('categories').select();
      return result.map((data) => FireStoreCategory.fromJson(data)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> addArticle(Article article) async {
    try {
      await _supabase.from('articles').insert(article.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }
}
