import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zad_aldaia/core/database/my_database.dart';
import 'package:zad_aldaia/features/add_category/data/models/firestore_category.dart';

class AddCategoryRepo {
  final MyDatabase _db;
  final supabase = Supabase.instance.client.from('categories');

  AddCategoryRepo(this._db);

  Future<bool> addCategory(FireStoreCategory category) async {
    try {
      await supabase.insert(category.toJson()).timeout(Duration(seconds: 30));
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }
}
