import 'package:zad_aldaia/features/article/data/models/article_item.dart';
import 'package:collection/collection.dart';

sealed class SearchState {}

class InitialState extends SearchState {}

class SearchingState extends SearchState {}

class LoadedState extends SearchState {
  final List<ArticleItem> items;
  LoadedState(this.items);
}
