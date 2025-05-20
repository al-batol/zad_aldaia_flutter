import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zad_aldaia/features/categories/data/models/category.dart';
import 'package:zad_aldaia/features/categories/data/repos/categories_repo.dart';
part './categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  final CategoriesRepo _repo;
  CategoriesCubit(this._repo) : super(LoadingState());

  List<Category> categories = [];

  Future saveCategory(Category category) async {
    // print("id: ${category.id}");
    // print(category.toFormJson());
    try {
      emit(SavingState());
      if (category.id.isEmpty) {
        await _repo.insertCategory(category.toFormJson());
      } else {
        await _repo.updateCategory(category.id, category.toFormJson());
      }
      emit(SavedState());
    } catch (e) {
      emit(ErrorState(e.toString()));
    }
  }

  loadCategories(Map<String, dynamic> eqMap) async {
    try {
      categories = (await searchCategories(eqMap));
      emit(ListLoadedState(categories));
    } catch (e) {
      emit(ErrorState(e.toString()));
    }
  }

  loadCategory(Map<String, dynamic> eqMap) async {
    try {
      categories = (await searchCategories(eqMap));
      if (categories.isEmpty) {
        emit(ErrorState('Not Found'));
      } else {
        emit(LoadedState(categories.first));
      }
    } catch (e) {
      emit(ErrorState(e.toString()));
    }
  }

  Future<Category?> findCategory(Map<String, dynamic> eqMap) async {
    final items = (await searchCategories(eqMap));
    return items.isEmpty ? null : items.first;
  }

  Future<List<Category>> searchCategories(Map<String, dynamic> eqMap) async {
    return await _repo.searchCategories(eqMap);
  }

  getChildCategories(String? parentId) async {
    var categories = await _repo.fetchCategories(parentId, null);
    this.categories = categories;
    emit(ListLoadedState(categories));
  }

  Future<bool> swapCategoriesOrder(String id1, String id2) async {
    return await _repo.swapCategoriesOrder(id1, id2);
  }
}
