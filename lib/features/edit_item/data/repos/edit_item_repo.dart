import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zad_aldaia/core/database/my_database.dart';
import 'package:zad_aldaia/core/extensions/article_item_extensions.dart';
import 'package:zad_aldaia/features/add_article/data/models/article.dart';
import 'package:zad_aldaia/features/add_category/data/models/firestore_category.dart';
import 'package:zad_aldaia/features/article/data/models/article_item.dart'
    as AI;

class EditItemRepo {
  final MyDatabase _db;
  final SupabaseClient _supabase;

  EditItemRepo(this._db, this._supabase);

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

  Future<bool> updateArticleItem(AI.ArticleItem articleItem) async {
    try {
      await _supabase
          .from('article_items')
          .upsert(articleItem.toJson(), onConflict: 'id');

      await updateVersion();
      return true;
    } catch (e) {
      print('Error updating article item: $e');
      return false;
    }
  }

  Future<String?> uploadImage(File image, String path, String oldPath) async {
    try {
      final currentPath = _extractFilePath(oldPath);
      final newPath = '$path/${DateTime.now().toIso8601String()}';
      await _supabase.storage.from('images').remove([currentPath]);
      await _supabase.storage
          .from('images')
          .upload(
            newPath,
            image,
            fileOptions: const FileOptions(upsert: false, cacheControl: '3600'),
          );
      final imageUrl = _supabase.storage.from('images').getPublicUrl(newPath);
      return imageUrl;
    } catch (e) {
      ('Error uploading image: $e');
      return null;
    }
  }

  String _extractFilePath(String url) {
    final uri = Uri.parse(url);
    final segments = uri.pathSegments;
    final publicIndex = segments.indexOf('public');
    if (publicIndex != -1 && publicIndex + 2 < segments.length) {
      // Skip the first segment after 'public'
      return segments.sublist(publicIndex + 2).join('/');
    } else {
      throw Exception('Invalid Supabase Storage URL');
    }
  }

  Future<AI.ArticleItem?> getItem(String id) async {
    try {
      final result =
          await _supabase.from('article_items').select().eq('id', id).single();
      return ArticleItem.fromJson(result).toArticleType();
    } catch (e) {
      print('Error getting item: $e');
      return null;
    }
  }

  Future<bool> deleteItem(String id) async {
    try {
      await _supabase.from('article_items').delete().eq('id', id);

      await addToDeletes(id);
      await updateVersion();
      return true;
    } catch (e) {
      print('Error deleting item: $e');
      return false;
    }
  }

  Future<void> addToDeletes(String id) async {
    await _supabase.from('deleted_items').insert({
      'id': id,
      'deleted_at': DateTime.now().toIso8601String(),
    });
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
