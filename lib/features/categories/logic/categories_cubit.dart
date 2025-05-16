import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zad_aldaia/features/categories/data/models/category.dart';
import 'package:zad_aldaia/features/categories/data/repos/categories_repo.dart';
import 'package:zad_aldaia/features/categories/logic/categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  final CategoriesRepo _repo;
  CategoriesCubit(this._repo) : super(LoadingState());

  List<Category> categories = [];
  getCategories(String section, String language) async {
    var categories = await _repo.getCategories(section, language);
    this.categories = categories;
    emit(LoadedState(categories));
  }

  getArticles(String section, String language) async {
    var categories = await _repo.getCategories(section, language);
    this.categories = categories;
    emit(LoadedState(categories));
  }

  swapCategoriesOrder(
    String id1,
    String id2,
    String section,
    String language,
  ) async {
    var result = await _repo.swapCategoriesOrder(id1, id2);
    if (result) {
      getCategories(section, language);
      emit(LoadedState(categories));
    }
  }

  /*search(String query) {
    emit(
      LoadedState(
        categories
            .where(
              (e) =>
                  e.title.contains(query) ||
                  e.articles.any((e) => e.contains(query)),
            )
            .toList(),
      ),
    );
  }*/
}
