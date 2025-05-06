import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zad_aldaia/features/add_article/data/models/article.dart';
import 'package:zad_aldaia/features/add_category/data/models/firestore_category.dart';
import 'package:zad_aldaia/features/article/data/models/article_item.dart';
import 'package:zad_aldaia/features/edit_item/data/repos/edit_item_repo.dart';
import 'package:zad_aldaia/features/edit_item/logic/edit_item_state.dart';

class EditItemCubit extends Cubit<EditItemState> {
  final EditItemRepo _repo;

  EditItemCubit(this._repo) : super(InitialState());

  Future<List<FireStoreCategory>> getCategories() async {
    return await _repo.getCategoriesList();
  }

  Future<List<Article>> getArticles() async {
    return await _repo.getArticlesList();
  }

  updateArticleItem(ArticleItem articleItem) async {
    print("ddddddddddddddddddddddd");
    emit(UploadingState());
    bool isUploaded = await _repo.updateArticleItem(articleItem);
    if (isUploaded) {
      emit(UploadedState());
    } else {
      emit(UploadFailedState());
    }
  }

  Future<String?> uploadImage(File image, String path, String oldPath) async {
    print("ssssssssssssssssssssssssssss");
    print('test');
    emit(UploadingState());
    var url = await _repo.uploadImage(image, path, oldPath);
    if (url == null) {
      emit(UploadFailedState());
    }
    return url;
  }

  Future<ArticleItem?> getItem(String id) async {
    return await _repo.getItem(id);
  }

  void deleteItem(String id) async {
    emit(DeletingState());
    bool isDeleted = await _repo.deleteItem(id);
    if (isDeleted) {
      emit(DeletedState());
    } else {
      emit(DeletingFailedState());
    }
  }
}
