import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:zad_aldaia/core/constants/firebase_constants.dart';
import 'package:zad_aldaia/core/database/my_database.dart';
import 'package:zad_aldaia/core/extensions/article_item_extensions.dart';
import 'package:zad_aldaia/features/add_article/data/models/article.dart';
import 'package:zad_aldaia/features/add_category/data/models/firestore_category.dart';
import 'package:zad_aldaia/features/article/data/models/article_item.dart' as AI;

class EditItemRepo{
  final MyDatabase _db;
  final firestore = FirebaseFirestore.instance;
  final firebaseStorage = FirebaseStorage.instance.ref().child("/images");

  EditItemRepo(this._db);


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

  Future<bool> updateArticleItem(AI.ArticleItem articleItem) async{
    try{
      await firestore
          .collection(FirebaseConstants.fireStoreDataCollection)
          .doc(articleItem.id)
          .set(articleItem.toJson());
      await updateVersion();
      return true;
    }catch(e){
      return false;
    }
  }

  Future<String?> uploadImage(File image,String path) async{
    try{
      var ref = firebaseStorage.child(path);
      await ref.putFile(image);
      return await ref.getDownloadURL();
    }catch(e){
      return null;
    }
  }

  Future<AI.ArticleItem?> getItem(String id) async{
    try{
      var result = await  firestore.collection(FirebaseConstants.fireStoreDataCollection).doc(id).get();
      if(result.data()!=null) {
        return ArticleItem.fromJson(result.data()!).toArticleType();
      }
      return null;
    }catch(e){
      return null;
    }

  }

  Future<bool> deleteItem(String id) async{
    try{
      await firestore.collection(FirebaseConstants.fireStoreDataCollection).doc(id).delete();
      await addToDeletes(id);
      await updateVersion();
      return true;
    }catch(e){
      return false;
    }
  }

  addToDeletes(String id)async{
    await firestore.collection(FirebaseConstants.fireStoreDeletesCollection).doc().set({"id":id});
  }

  updateVersion() async{
    await firestore
        .collection(FirebaseConstants.fireStoreVersionCollection)
        .doc(FirebaseConstants.fireStoreVersionCollection)
        .update({
      'version': FieldValue.increment(1), // Increment by 1
    });
  }


}