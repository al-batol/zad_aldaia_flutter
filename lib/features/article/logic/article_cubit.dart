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

  String? articleId;
  List<ArticleItem> items = [];

  swapArticleItemOrders(String id1, String id2) async {
    await _repo.swapArticleItemOrders(id1, id2);
    getItems();
  }

  Future<void> getItems() async {
    assert(articleId != null);
    emit(LoadingState());
    final response = await _supabase.from('article_items').select().eq('article_id', articleId!).order('order', ascending: true);

    print(response);
    // تحويل البيانات إلى ArticleItem
    items = response.map<ArticleItem>((item) => ArticleItem.fromJson(item)).toList();

    print("ids ${items.map((e) => e.id).toList()}");
    // ترتيب العناصر
    items.sort((a, b) => a.order.compareTo(b.order));
    print("ids ${items.map((e) => e.id).toList()}");

    emit(LoadedState(items));
  }

  search(String query) {
    emit(
      LoadedState(
        items.where((e) {
          bool x = e.note.contains(query);
          if (e.type == ArticleType.Text) {
            return x || (e as TextArticle).title.contains(query) || e.content.contains(query);
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
}
