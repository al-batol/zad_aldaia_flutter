import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zad_aldaia/core/database/my_database.dart';
import 'package:http/http.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:external_path/external_path.dart';
import 'package:image_downloader_web/image_downloader_web.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:zad_aldaia/core/extensions/article_item_extensions.dart';
import 'package:zad_aldaia/core/networking/api_service.dart';
import 'package:zad_aldaia/core/networking/translation_request.dart';
import 'package:zad_aldaia/features/article/data/models/article_item.dart'
    as article_item;

import '../../../../core/database/my_database.dart' as AI;

class ArticleRepo {
  final MyDatabase _db;
  final ApiService _apiService;

  final SupabaseClient _supabase;

  ArticleRepo(this._db, this._apiService, this._supabase);

  Future<String?> translateText(text, language) async {
    try {
      var response = await _apiService.translateText(
        TranslationRequest(text, language),
      );
      return response.data.translations.first.translatedText;
    } catch (e) {
      return null;
    }
  }

  List<article_item.ArticleItem> _cachedItems = [];
  Future<List<article_item.ArticleItem>> getArticleItems(
    String article,
    String category,
    String section,
    String language,
  ) async {
    var items =
        await (_db.select(_db.articleItems)..where(
          (tbl) =>
              tbl.section.equals(section) &
              tbl.category.equals(category) &
              tbl.article.equals(article) &
              tbl.language.equals(language),
        )).get();
    _cachedItems = items.map((e) => e.toArticleType()).toList(); // تخزينها
    return items.map((e) {
      return e.toArticleType();
    }).toList();
  }

  saveImageAndroid(String imageUrl) async {
    var status = await Permission.storage.request();
    var androidVersion = (await DeviceInfoPlugin().androidInfo).version.release;
    if (status.isGranted || int.parse(androidVersion) >= 11) {
      var response = await get(Uri.parse(imageUrl));
      var downloadDirectory =
          await ExternalPath.getExternalStoragePublicDirectory(
            ExternalPath.DIRECTORY_DOWNLOAD,
          );
      var filePathAndName = '$downloadDirectory/${Uuid().v4()}.jpg';
      File file = File(filePathAndName);
      await file.writeAsBytes(response.bodyBytes);
    }
  }

  saveImageWeb(String imageUrl) async {
    try {
      await WebImageDownloader.downloadImageFromWeb(
        imageUrl,
        name: Uuid().v4(),
      );
    } catch (e) {
      print(e);
    }
  }

  Future<bool> updateArticleItem(AI.ArticleItem articleItem) async {
    try {
      await _supabase
          .from('article_items')
          .upsert(articleItem.toJson(), onConflict: 'id');

      return true;
    } catch (e) {
      print('Error updating article item: $e');
      return false;
    }
  }

  Future<bool> reorderArticleItem({
    required String id,
    required int newIndex,
  }) async {
    try {
      if (_cachedItems.isEmpty) return false;

      print("Reordering... id: $id newIndex: $newIndex");

      _cachedItems.sort((a, b) => a.order.compareTo(b.order));

      print(
        "Old order: ${_cachedItems.map((e) => e.order).toList()}  id: ${_cachedItems.map((e) => e.id).toList()}",
      );

      final movedItem = _cachedItems.firstWhere((item) => item.id == id);
      _cachedItems.remove(movedItem);

      print("Removed item: $movedItem");

      _cachedItems.insert(newIndex, movedItem);

      print("Inserted item: $movedItem");

      for (int i = 0; i < _cachedItems.length; i++) {
        _cachedItems[i].order = i + 1;
      }
      print(
        "Updated order: ${_cachedItems.map((e) => e.order).toList()} id: ${_cachedItems.map((e) => e.id).toList()}",
      );

      for (final item in _cachedItems) {
        await _supabase
            .from('article_items')
            .update({'order': item.order})
            .eq('id', item.id);
        print("Updated item: $item");
        print("Updated item: ${item.id} to order: ${item.order}");
      }

      print("✅ Reordering completed successfully for item: $id");
      print(
        "New order: ${_cachedItems.map((e) => e.order).toList()} id: ${_cachedItems.map((e) => e.id).toList()}",
      );
      return true;
    } catch (e) {
      print('❌ Error reordering article item: $e');
      return false;
    }
  }
}
