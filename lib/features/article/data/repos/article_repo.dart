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
import 'package:zad_aldaia/features/article/data/models/article_item.dart' as article_item;

class ArticleRepo {
  final MyDatabase _db;
  final ApiService _apiService;

  final SupabaseClient _supabase;

  ArticleRepo(this._db, this._apiService, this._supabase);

  Future<String?> translateText(text, language) async {
    try {
      var response = await _apiService.translateText(TranslationRequest(text, language));
      return response.data.translations.first.translatedText;
    } catch (e) {
      return null;
    }
  }

  Future<List<article_item.ArticleItem>> getArticleItems(String articleId) async {
    var items = await (_db.select(_db.articleItems)..where((tbl) => tbl.articleId.equals(articleId))).get();
    return items.map((e) {
      return e.toArticleType();
    }).toList();
  }

  saveImageAndroid(String imageUrl) async {
    var status = await Permission.storage.request();
    var androidVersion = (await DeviceInfoPlugin().androidInfo).version.release;
    if (status.isGranted || int.parse(androidVersion) >= 11) {
      var response = await get(Uri.parse(imageUrl));
      var downloadDirectory = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD);
      var filePathAndName = '$downloadDirectory/${Uuid().v4()}.jpg';
      File file = File(filePathAndName);
      await file.writeAsBytes(response.bodyBytes);
    }
  }

  saveImageWeb(String imageUrl) async {
    try {
      await WebImageDownloader.downloadImageFromWeb(imageUrl, name: Uuid().v4());
    } catch (e) {
      print(e);
    }
  }

  Future<bool> updateArticleItem(article_item.ArticleItem articleItem) async {
    try {
      await _supabase.from('article_items').upsert(articleItem.toJson(), onConflict: 'id');

      return true;
    } catch (e) {
      print('Error updating article item: $e');
      return false;
    }
  }

  Future<bool> swapArticleItemOrders(String id1, String id2) async {
    try {
      final response = await _supabase.from('article_items').select('id, order').or('id.eq.$id1,id.eq.$id2');

      if (response.length != 2) {
        print('❌ One or both IDs not found.');
        return false;
      }

      final order1 = response.firstWhere((item) => item['id'] == id1)['order'];
      print('order1: $order1');
      final order2 = response.firstWhere((item) => item['id'] == id2)['order'];
      print('order2: $order2');

      await _supabase.from('article_items').update({'order': order2}).eq('id', id1);
      await _supabase.from('article_items').update({'order': order1}).eq('id', id2);

      print('✅ Orders swapped between ID $id1 and ID $id2');
      return true;
    } catch (e) {
      print('Error swapping article item orders: $e');
      return false;
    }
  }
}
