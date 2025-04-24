import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zad_aldaia/features/add_article/data/models/article.dart';
import 'package:zad_aldaia/features/add_category/data/models/firestore_category.dart';
import 'package:zad_aldaia/features/add_item/data/repos/add_item_repo.dart';
import 'package:zad_aldaia/features/add_item/logic/add_item_state.dart';
import 'package:zad_aldaia/features/article/data/models/article_item.dart';

class AddItemCubit extends Cubit<AddItemState> {
  final AddItemRepo _repo;

  AddItemCubit(this._repo) : super(InitialState());

  Future<List<FireStoreCategory>> getCategories() async {
    return await _repo.getCategoriesList();
  }

  Future<List<Article>> getArticles() async {
    return await _repo.getArticlesList();
  }

  addArticleItem(ArticleItem textArticle) async {
    emit(UploadingState());
    bool isUploaded = await _repo.addArticleItem(textArticle);
    if (isUploaded) {
      emit(UploadedState());
    } else {
      emit(UploadFailedState());
    }
  }

  Future<String?> uploadImage(File image, String path) async {
    emit(UploadingState());
    var url = await _repo.uploadImage(image, path);
    if (url == null) {
      emit(UploadFailedState());
    }
    return url;
  }
}
