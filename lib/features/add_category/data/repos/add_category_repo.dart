import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zad_aldaia/core/constants/firebase_constants.dart';
import 'package:zad_aldaia/core/database/my_database.dart';
import 'package:zad_aldaia/features/add_category/data/models/firestore_category.dart';

class AddCategoryRepo {
  final MyDatabase _db;
  final firestore = FirebaseFirestore.instance;

  AddCategoryRepo(this._db);

  Future<bool> addCategory(FireStoreCategory category) async {
    try {
      await firestore
          .collection(FirebaseConstants.fireStoreCategoriesCollection)
          .add(category.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }
}
