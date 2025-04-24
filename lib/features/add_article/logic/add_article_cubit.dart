import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zad_aldaia/features/add_article/data/models/article.dart';
import 'package:zad_aldaia/features/add_article/data/repos/add_article_repo.dart';
import 'package:zad_aldaia/features/add_article/logic/add_article_state.dart';
import 'package:zad_aldaia/features/add_category/data/models/firestore_category.dart';

class AddArticleCubit extends Cubit<AddArticleState>{

  final AddArticleRepo _repo;

  AddArticleCubit(this._repo):super(InitialState());

  Future<List<FireStoreCategory>> getCategories()async{
    return await _repo.getCategoriesList();
  }

   addArticle(Article article)async{
    emit(UploadingState());
    bool isUploaded = await _repo.addArticle(article);
    if(isUploaded){
      emit(UploadedState());
    }else{
      emit(UploadFailedState());
    }
  }

}