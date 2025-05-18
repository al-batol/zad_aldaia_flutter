import 'package:zad_aldaia/features/article/data/models/article_item.dart';

sealed class SearchState{

}

class InitialState extends SearchState{

}

class SearchingState extends SearchState {
  final String query;

  SearchingState({required this.query});
}

class SearchLoadedState extends SearchState {
  final List<ArticleItem> items;
  final String query;

  SearchLoadedState(this.items, {required this.query});
}
