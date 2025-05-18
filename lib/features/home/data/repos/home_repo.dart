import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zad_aldaia/core/constants/shared_preferences_keys.dart';
import 'package:zad_aldaia/core/database/my_database.dart';
import 'package:zad_aldaia/core/models/article_type.dart';

class HomeRepo {
  final MyDatabase _dp;
  final SharedPreferences sp;
  final SupabaseClient _supabase;

  HomeRepo(this._dp, this.sp, this._supabase);

  Future<int> getLastVersion() async {
    try {
      final result = await _supabase.from('version').select('version').single();

      return result['version'] as int;
    } catch (e) {
      print('Error getting version: $e');
      return 0;
    }
  }

  updateData(int version) async {
    await saveItems();
    await checkDeletes();
    await saveDataVersion(version);
  }

  Future<void> saveItems() async {
    int offset = 0;
    const limit = 100;

    while (true) {
      try {
        final result = await _supabase
            .from('article_items')
            .select()
            .order('id')
            .range(offset, offset + limit - 1);

        if (result.isEmpty) {
          break;
        }

        final articleItems =
            (result as List<dynamic>)
                .map((data) => articleFromFirestore(data))
                .toList();

        await Future.wait(
          articleItems.map((articleItem) async {
            await _saveArticleItem(articleItem);
          }),
        );

        offset += limit;

        if (result.length < limit) {
          break; // No more items to fetch
        }
      } catch (e) {
        print('Error saving items: $e');
        break;
      }
    }
  }

  ArticleItem articleFromFirestore(Map<String, dynamic> data) {
    return ArticleItem(
      id: data["id"] ?? "",
      section: data["section"] ?? "",
      category: data["category"] ?? "",
      article: data["article"] ?? "",
      language: data["language"],
      type: ArticleTypeExtension.valueOf(data["type"]),
      title: data["title"],
      content: data["content"],
      note: data["note"],
      videoId: data["videoId"],
      url: data["url"],
      order: data["order"],
      backgroundColor: data["backgroundColor"],
    );
  }

  _saveArticleItem(ArticleItem articleItem) async {
    await _dp
        .into(_dp.articleItems)
        .insert(articleItem, onConflict: DoUpdate((old) => articleItem));
  }

  Future<void> checkDeletes() async {
    try {
      final result = await _supabase.from('deleted_items').select('id');

      if (result.isNotEmpty) {
        final deletesId =
            (result as List<dynamic>)
                .map((item) => item['id'] as String)
                .toList();

        await Future.wait(deletesId.map((id) async => await deleteArticle(id)));
      }
    } catch (e) {
      print('Error checking deletes: $e');
    }
  }

  deleteArticle(String id) async {
    await (_dp.delete(_dp.articleItems)
      ..where((tbl) => tbl.id.equals(id))).go();
  }

  saveDataVersion(int version) {
    sp.setInt(SpKeys.dataVersionKey, version);
  }

  Future<bool> signIn(String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: '$password@admin.com',
        password: password,
      );

      return response.user != null;
    } catch (e) {
      print('Error signing in: $e');
      return false;
    }
  }

  Future<bool> isAuthenticated() async {
    return _supabase.auth.currentUser != null;
  }
}
