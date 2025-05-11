import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zad_aldaia/features/article/data/models/article_item.dart';
import 'package:zad_aldaia/features/search/data/repos/search_repo.dart';
import 'package:zad_aldaia/features/search/logic/search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchRepo _repo;

  SearchCubit(this._repo) : super(InitialState());

  search(String query) async {
    emit(SearchingState());
    List<ArticleItem> items = await _repo.searchArticleItems(query);
    if (query.isEmpty || items.isEmpty) {
      emit(LoadedState([]));
    } else {
      emit(LoadedState(items));
    }
  }

  void clearResults() {
    emit(LoadedState([]));
  }

  saveImageAndroid(String imageUrl) async {
    await _repo.saveImageAndroid(imageUrl);
  }

  saveImageWeb(String imageUrl) async {
    await _repo.saveImageWeb(imageUrl);
  }
}
