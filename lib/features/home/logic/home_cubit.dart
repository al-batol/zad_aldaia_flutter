import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zad_aldaia/core/constants/shared_preferences_keys.dart';
import 'package:zad_aldaia/core/models/languge.dart';
import 'package:zad_aldaia/features/home/data/repos/home_repo.dart';

class HomeCubit extends Cubit {
  final HomeRepo repo;
  final SharedPreferences sp;
  String language = Language.english;

  HomeCubit({required this.repo, required this.sp}) : super(null);

  checkForDataUpdates() async {
    int version = await repo.getLastVersion();
    if (sp.getInt(SpKeys.dataVersionKey) != version) {
      await repo.updateData(version);
    }
  }

  Future<bool> signIn(String password) async {
    return await repo.signIn(password);
  }

  Future<bool> isAuthenticated() async {
    return await repo.isAuthenticated();
  }

}
