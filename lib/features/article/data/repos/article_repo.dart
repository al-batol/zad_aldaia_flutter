import 'package:drift/drift.dart';
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

class ArticleRepo {
  final MyDatabase _db;
  final ApiService _apiService;

  ArticleRepo(this._db, this._apiService);

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
}
