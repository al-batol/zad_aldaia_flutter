import 'package:zad_aldaia/features/article/data/models/article_item.dart';

sealed class ArticleState {}

class LoadingState extends ArticleState {}

class LoadedState extends ArticleState {
  final List<ArticleItem> items;
  LoadedState(this.items);
}

class UpdateLoadingState extends ArticleState {}

class UpdateSuccesState extends ArticleState {}

class UpdateFailedState extends ArticleState {}
