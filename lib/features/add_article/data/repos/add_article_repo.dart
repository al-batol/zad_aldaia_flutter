import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:zad_aldaia/core/constants/firebase_constants.dart';
import 'package:zad_aldaia/core/database/my_database.dart';
import 'package:zad_aldaia/features/add_article/data/models/article.dart';
import 'package:zad_aldaia/features/add_category/data/models/firestore_category.dart';

class AddArticleRepo {
  final MyDatabase _dp;
  final firestore = FirebaseFirestore.instance;

  AddArticleRepo(this._dp);

  Future<List<FireStoreCategory>> getCategoriesList() async {
    try {
      var result =
          await firestore
              .collection(FirebaseConstants.fireStoreCategoriesCollection)
              .get();
      return result.docs.map((element) {
        return FireStoreCategory.fromJson(element.data());
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> addArticle(Article article) async {
    try {
      await firestore
          .collection(FirebaseConstants.fireStoreArticlesCollection)
          .add(article.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }
}
