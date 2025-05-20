import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zad_aldaia/features/items/data/models/item.dart';
import 'package:zad_aldaia/features/items/data/repos/items_repo.dart';
part './items_state.dart';

class ItemsCubit extends Cubit<ItemsState> {
  final ItemsRepo _repo;
  ItemsCubit(this._repo) : super(LoadingState());

  List<Item> items = [];

  Future saveItem(Item item) async {
    print("id: ${item.id}");
    print(item.toFormJson());
    try {
      emit(SavingState());
      if (item.id.isEmpty) {
        await _repo.insertItem(item.toFormJson());
      } else {
        await _repo.updateItem(item.id, item.toFormJson());
      }
      emit(SavedState());
    } catch (e) {
      emit(ErrorState(e.toString()));
    }
  }

  loadItems(Map<String, dynamic> eqMap) async {
    emit(LoadingState());
    try {
      items = (await searchItems(eqMap));
      print(items);
      emit(ListLoadedState(items));
    } catch (e) {
      emit(ErrorState(e.toString()));
    }
  }

  loadItem(Map<String, dynamic> eqMap) async {
    try {
      items = (await searchItems(eqMap));
      if (items.isEmpty) {
        emit(ErrorState('Not Found'));
      } else {
        emit(LoadedState(items.first));
      }
    } catch (e) {
      emit(ErrorState(e.toString()));
    }
  }

  Future<Item?> findItem(Map<String, dynamic> eqMap) async {
    final items = (await searchItems(eqMap));
    return items.isEmpty ? null : items.first;
  }

  Future<List<Item>> searchItems(Map<String, dynamic> eqMap) async {
    return await _repo.searchItems(eqMap);
  }

  Future<bool> swapItemsOrder(String id1, String id2) async {
    return await _repo.swapItemsOrder(id1, id2);
  }
}
