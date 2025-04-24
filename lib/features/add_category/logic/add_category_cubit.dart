import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zad_aldaia/features/add_category/data/models/firestore_category.dart';
import 'package:zad_aldaia/features/add_category/data/repos/add_category_repo.dart';
import 'package:zad_aldaia/features/add_category/logic/add_category_state.dart';

class AddCategoryCubit extends Cubit<AddCategoryState>{
  final AddCategoryRepo _repo;

  AddCategoryCubit(this._repo):super(InitialState());

  addCategory(FireStoreCategory category)async{
    emit(UploadingState());
    bool isUploaded = await _repo.addCategory(category);
    if(isUploaded){
       emit(UploadedState());
    }else{
      emit(UploadFailedState());
    }
  }

}