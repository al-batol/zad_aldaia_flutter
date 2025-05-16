import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zad_aldaia/features/article/data/models/article_item.dart';
import 'package:zad_aldaia/features/article/data/repos/article_repo.dart';
import 'package:zad_aldaia/features/article/logic/article_state.dart';
import 'package:zad_aldaia/core/models/article_type.dart';

class ArticleCubit extends Cubit<ArticleState> {
  final ArticleRepo _repo;
  final SupabaseClient _supabase;

  ArticleCubit(this._repo, this._supabase) : super(LoadingState());

  List<ArticleItem> items = [];

  Future<void> getArticles(
    String section,
    String language,
    String category,
    String article,
  ) async {
    emit(LoadingState());
    final response = await _supabase
        .from('article_items')
        .select()
        .eq('section', section)
        .eq('language', language)
        .eq('category', category)
        .eq('article', article)
        .order('order', ascending: true);

    print(response);
    // تحويل البيانات إلى ArticleItem
    items =
        response
            .map<ArticleItem>((item) => ArticleItem.fromJson(item))
            .toList();

    print("ids ${items.map((e) => e.id).toList()}");
    // ترتيب العناصر
    items.sort((a, b) => a.order.compareTo(b.order));
    print("ids ${items.map((e) => e.id).toList()}");

    emit(LoadedState(items));
  }

  /*getArticles(
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
  }*/

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

  updateArticle(ArticleItem articleItem) async {
    await _repo.updateArticleItem(articleItem);
  }

  swapArticleItemOrders(
    String id1,
    String id2,
    String section,
    String language,
    String category,
    String article,
  ) async {
    emit(LoadingState());
    await _repo.swapArticleItemOrders(id1, id2);
    getArticles(section, language, category, article);
    emit(LoadedState(items));
  }
}
