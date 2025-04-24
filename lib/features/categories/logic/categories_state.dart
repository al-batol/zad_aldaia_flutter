import 'package:zad_aldaia/features/categories/data/models/category.dart';

sealed class CategoriesState{
}

class LoadingState extends CategoriesState{}

class LoadedState extends CategoriesState{
  final List<Category> categories;

  LoadedState(this.categories);
}

