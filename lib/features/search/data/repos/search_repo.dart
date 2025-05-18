import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:drift/drift.dart';
import 'package:external_path/external_path.dart';
import 'package:http/http.dart';
import 'package:image_downloader_web/image_downloader_web.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:zad_aldaia/core/database/my_database.dart';
import 'package:zad_aldaia/core/extensions/article_item_extensions.dart';
import 'package:zad_aldaia/features/article/data/models/article_item.dart'
    as article_item;

class SearchRepo {
  final MyDatabase _db;

  SearchRepo(this._db);

  Future<List<article_item.ArticleItem>> searchArticleItems(
    String query,
  ) async {
    print(query);
    var items =
        await (_db.select(_db.articleItems)..where(
          (tbl) =>
              tbl.section.contains(query) |
              tbl.category.contains(query) |
              tbl.article.contains(query) |
              tbl.title.contains(query) |
              tbl.content.contains(query) |
              tbl.note.contains(query),
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
