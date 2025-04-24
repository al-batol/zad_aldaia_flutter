import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zad_aldaia/features/categories/data/models/category.dart';
import 'package:zad_aldaia/features/categories/data/repos/categories_repo.dart';
import 'package:zad_aldaia/features/categories/logic/categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  final CategoriesRepo _repo;
  late final List<Category> categories;

  CategoriesCubit(this._repo) : super(LoadingState());

  getCategories(String section, String language) async {
    var categories = await _repo.getSectionCategories(section, language);
    this.categories = categories;
    emit(LoadedState(categories));
  }

  search(String query) {
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
  }
}
