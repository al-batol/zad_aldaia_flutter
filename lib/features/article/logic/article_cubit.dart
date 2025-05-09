import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zad_aldaia/features/article/data/models/article_item.dart';
import 'package:zad_aldaia/features/article/data/repos/article_repo.dart';
import 'package:zad_aldaia/features/article/logic/article_state.dart';
import 'package:zad_aldaia/core/models/article_type.dart';

class ArticleCubit extends Cubit<ArticleState> {
  final ArticleRepo _repo;
  List<ArticleItem> items = [];

  ArticleCubit(this._repo) : super(LoadingState());

  getArticles(
    String section,
    String language,
    String category,
    String article,
  ) async {
    List<ArticleItem> items = await _repo.getArticleItems(
      article,
      category,
      section,
      language,
    );
    items.sort((a, b) => a.order.compareTo(b.order));
    this.items = items;
    emit(LoadedState(items));
  }

  search(String query) {
    emit(
      LoadedState(
        items.where((e) {
          bool x = e.note.contains(query);
          if (e.type == ArticleType.Text) {
            return x ||
                (e as TextArticle).title.contains(query) ||
                e.content.contains(query);
          }
          return x;
        }).toList(),
      ),
    );
  }

  saveImageAndroid(String imageUrl) async {
    await _repo.saveImageAndroid(imageUrl);
  }

  saveImageWeb(String imageUrl) async {
    await _repo.saveImageWeb(imageUrl);
  }

  Future<String?> translateText(text, language) async {
    return await _repo.translateText(text, language);
  }

  Future<bool> updateArticleOrder(String id, int newIndex) async {
    emit(UpdateLoadingState());
    try {
      final success = await _repo.reorderArticleItem(
        id: id,
        newIndex: newIndex,
      );

      if (success) {
        emit(LoadedState(items));
        return true;
      } else {
        emit(LoadedState(items));
        return false;
      }
    } catch (e) {
      print("updateArticleOrder error: $e");
      emit(UpdateFailedState());
      return false;
    }
  }
}
