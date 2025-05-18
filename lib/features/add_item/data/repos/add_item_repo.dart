import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zad_aldaia/features/add_article/data/models/article.dart';
import 'package:zad_aldaia/features/add_category/data/models/firestore_category.dart';
import 'package:zad_aldaia/features/article/data/models/article_item.dart'
    as AI;
import 'package:zad_aldaia/core/database/my_database.dart';

class AddItemRepo {
  final MyDatabase _dp;
  final SupabaseClient _supabase;

  AddItemRepo(this._dp, this._supabase);

  Future<List<FireStoreCategory>> getCategoriesList() async {
    try {
      final result = await _supabase.from('categories').select();
      return result.map((data) => FireStoreCategory.fromJson(data)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Article>> getArticlesList() async {
    try {
      final result = await _supabase.from('articles').select();
      return result.map((data) => Article.fromJson(data)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> addArticleItem(AI.ArticleItem articleItem) async {
    try {
      final json = articleItem.toJson();

      // ✅ تحقق من أن جميع القيم الأساسية ليست null أو فاضية
      for (final key in ['id', 'section', 'category', 'article', 'language', 'note', 'order', 'type']) {
        if (json[key] == null || (json[key] is String && json[key].trim().isEmpty)) {
          print('❌ Missing required field: $key');
          return false;
        }
      }

      if (json['type'] == 'Text') {
        for (final key in ['title', 'content', 'backgroundColor']) {
          if (json[key] == null || (json[key] is String && json[key].trim().isEmpty)) {
            print('❌ Missing required TextArticle field: $key');
            return false;
          }
        }
      }

      print("📦 Sending to Supabase: $json");
      await _supabase.from('article_items').upsert(json);
      await updateVersion();
      return true;
    } catch (e, s) {
      print('❌ Error in addArticleItem');
      print(e.toString());
      print(s);
      return false;
    }
  }
  Future<String?> uploadImage(File image, String path) async {
    try {
      final now = DateTime.now().toIso8601String();
      final filePath = '$path/$now';
      await _supabase.storage
          .from('images')
          .upload(
            filePath,
            image,
            fileOptions: const FileOptions(upsert: false, cacheControl: '3600'),
          );

      final imageUrl = _supabase.storage.from('images').getPublicUrl(filePath);
      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> updateVersion() async {
    try {
      final result =
          await _supabase
              .from('version')
              .select('version')
              .eq('id', 1)
              .single();

      int currentVersion = result['version'];

      await _supabase
          .from('version')
          .update({
            'version': currentVersion + 1,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', 1);
    } catch (e) {
      print('Error updating version: $e');
    }
  }
}
