import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:zad_aldaia/core/constants/firebase_constants.dart';
import 'package:zad_aldaia/features/add_article/data/models/article.dart';
import 'package:zad_aldaia/features/add_category/data/models/firestore_category.dart';
import 'package:zad_aldaia/features/article/data/models/article_item.dart'
    as AI;
import 'package:zad_aldaia/core/database/my_database.dart';

class AddItemRepo {
  final MyDatabase _dp;
  final firestore = FirebaseFirestore.instance;
  final firebaseStorage = FirebaseStorage.instance.ref().child("/images");

  AddItemRepo(this._dp);

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

  Future<List<Article>> getArticlesList() async {
    try {
      var result =
          await firestore
              .collection(FirebaseConstants.fireStoreArticlesCollection)
              .get();
      return result.docs.map((element) {
        return Article.fromJson(element.data());
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> addArticleItem(AI.ArticleItem articleItem) async {
    try {
      await firestore
          .collection(FirebaseConstants.fireStoreDataCollection)
          .doc(articleItem.id)
          .set(articleItem.toJson());
      await updateVersion();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> uploadImage(File image, String path) async {
    try {
      var ref = firebaseStorage.child(path);
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  updateVersion() async {
    await firestore
        .collection(FirebaseConstants.fireStoreVersionCollection)
        .doc(FirebaseConstants.fireStoreVersionCollection)
        .update({
          'version': FieldValue.increment(1), // Increment by 1
        });
  }
}
