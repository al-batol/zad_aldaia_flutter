import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zad_aldaia/core/database/my_database.dart';
import 'package:zad_aldaia/core/networking/api_service.dart';
import 'package:zad_aldaia/core/networking/dio_factory.dart';
import 'package:zad_aldaia/features/add_article/data/repos/add_article_repo.dart';
import 'package:zad_aldaia/features/add_article/logic/add_article_cubit.dart';
import 'package:zad_aldaia/features/add_category/data/repos/add_category_repo.dart';
import 'package:zad_aldaia/features/add_category/logic/add_category_cubit.dart';
import 'package:zad_aldaia/features/add_item/data/repos/add_item_repo.dart';
import 'package:zad_aldaia/features/add_item/logic/add_item_cubit.dart';
import 'package:zad_aldaia/features/article/data/repos/article_repo.dart';
import 'package:zad_aldaia/features/article/logic/article_cubit.dart';
import 'package:zad_aldaia/features/categories/data/repos/categories_repo.dart';
import 'package:zad_aldaia/features/categories/logic/categories_cubit.dart';
import 'package:zad_aldaia/features/edit_item/data/repos/edit_item_repo.dart';
import 'package:zad_aldaia/features/edit_item/logic/edit_item_cubit.dart';
import 'package:zad_aldaia/features/home/data/repos/home_repo.dart';
import 'package:zad_aldaia/features/home/logic/home_cubit.dart';
import 'package:zad_aldaia/features/search/data/repos/search_repo.dart';
import 'package:zad_aldaia/features/search/logic/search_cubit.dart';

final getIt = GetIt.instance;

setupGetIt() async {
  getIt.registerLazySingleton<MyDatabase>(() => MyDatabase());
  final SharedPreferences sp = await SharedPreferences.getInstance();
  final Dio dio = DioFactory.getDio();
  final SupabaseClient supabaseClient = Supabase.instance.client;
  getIt.registerSingleton<SharedPreferences>(sp);
  getIt.registerSingleton<Dio>(dio);
  getIt.registerSingleton<SupabaseClient>(supabaseClient);
  getIt.registerFactory<HomeRepo>(
    () => HomeRepo(getIt(), getIt(), supabaseClient),
  );
  getIt.registerFactory<HomeCubit>(() => HomeCubit(repo: getIt(), sp: getIt()));
  getIt.registerFactory<CategoriesRepo>(() => CategoriesRepo(getIt()));
  getIt.registerFactory<CategoriesCubit>(() => CategoriesCubit(getIt()));
  getIt.registerFactory<ApiService>(() => ApiService(dio));
  getIt.registerFactory<ArticleRepo>(
    () => ArticleRepo(getIt(), getIt(), supabaseClient),
  );
  getIt.registerFactory<ArticleCubit>(
    () => ArticleCubit(getIt(), supabaseClient),
  );
  getIt.registerFactory<SearchRepo>(() => SearchRepo(getIt()));
  getIt.registerFactory<SearchCubit>(() => SearchCubit(getIt()));
  getIt.registerFactory<AddArticleRepo>(
    () => AddArticleRepo(getIt(), supabaseClient),
  );
  getIt.registerFactory<AddArticleCubit>(() => AddArticleCubit(getIt()));
  getIt.registerFactory<AddCategoryRepo>(() => AddCategoryRepo(getIt()));
  getIt.registerFactory<AddCategoryCubit>(() => AddCategoryCubit(getIt()));
  getIt.registerFactory<AddItemRepo>(
    () => AddItemRepo(getIt(), supabaseClient),
  );
  getIt.registerFactory<AddItemCubit>(() => AddItemCubit(getIt()));
  getIt.registerFactory<EditItemRepo>(
    () => EditItemRepo(getIt(), supabaseClient),
  );
  getIt.registerFactory<EditItemCubit>(() => EditItemCubit(getIt()));
}
