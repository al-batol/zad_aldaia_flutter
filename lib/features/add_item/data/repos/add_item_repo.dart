import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zad_aldaia/core/constants/firebase_constants.dart';
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
      await _supabase.from('article_items').upsert(articleItem.toJson());
      await updateVersion();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> uploadImage(File image, String path) async {
    try {
      final now = DateTime.now().toIso8601String();
      final filePath = path + now;
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
