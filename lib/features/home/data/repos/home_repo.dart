import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zad_aldaia/core/constants/firebase_constants.dart';
import 'package:zad_aldaia/core/constants/shared_preferences_keys.dart';
import 'package:zad_aldaia/core/database/my_database.dart';
import 'package:zad_aldaia/core/models/article_type.dart';

class HomeRepo {
  final MyDatabase _dp;
  final SharedPreferences sp;
  final fireStore = FirebaseFirestore.instance;

  HomeRepo(this._dp, this.sp);

  Future<int> getLastVersion() async {
    var result =
        await fireStore
            .collection(FirebaseConstants.fireStoreVersionCollection)
            .doc(FirebaseConstants.fireStoreVersionCollection)
            .get();
    return result["version"];
  }

  updateData(int version) async {
    await saveItems();
    await checkDeletes();
    await saveDataVersion(version);
  }

  saveItems() async {
    DocumentSnapshot? lastDocument;
    var query = fireStore
        .collection(FirebaseConstants.fireStoreDataCollection)
        .orderBy("id")
        .limit(100);

    while (true) {
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }
      var result = await query.get();
      if (result.docs.isEmpty) {
        break;
      }
      final articleItems =
          result.docs.map((doc) => articleFromFirestore(doc.data())).toList();
      await Future.wait(
        articleItems.map((articleItem) async {
          await _saveArticleItem(articleItem);
        }),
      );
      lastDocument = result.docs.lastOrNull;
      if (lastDocument == null) {
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
    );
  }

  _saveArticleItem(ArticleItem articleItem) async {
    await _dp
        .into(_dp.articleItems)
        .insert(articleItem, onConflict: DoUpdate((old) => articleItem));
  }

  checkDeletes() async {
    var result =
        await fireStore
            .collection(FirebaseConstants.fireStoreDeletesCollection)
            .get();
    if (result.docs.isNotEmpty) {
      var deletesId = result.docs.map((e) => e["id"] as String).toList();
      await Future.wait(deletesId.map((id) async => await deleteArticle(id)));
    }
  }

  deleteArticle(String id) async {
    await (_dp.delete(_dp.articleItems)
      ..where((tbl) => tbl.id.equals(id))).go();
  }

  saveDataVersion(int version) {
    sp.setInt(SpKeys.dataVersionKey, version);
  }

  Future<bool> validatePassword(String password) async {
    try {
      bool isCorrect =
          (await fireStore
                  .collection(FirebaseConstants.fireStoreAdminCollection)
                  .doc(password)
                  .get())
              .exists;
      return isCorrect;
    } catch (e) {
      return false;
    }
  }
}
