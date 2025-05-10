import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zad_aldaia/features/categories/data/models/category.dart';
import 'package:zad_aldaia/features/categories/data/repos/categories_repo.dart';
import 'package:zad_aldaia/features/categories/logic/categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  final CategoriesRepo _repo;
  late final List<Category> categories;

  CategoriesCubit(this._repo) : super(LoadingState());

  getCategories(String section, String language) async {
    var categories = await _repo.getCategoriesFromSupabase(section, language);
    this.categories = categories;
    print("categories: ${categories.map((e) => e.order).toList()}");
    emit(LoadedState(categories));
  }

  reOrderCategories(String id, int newIndex) async {
    emit(LoadingState());
    try {
      await _repo.reOderCategories(id, newIndex);
      emit(LoadedState(categories));
    } catch (e) {
      emit(ErrorState(e.toString()));
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
