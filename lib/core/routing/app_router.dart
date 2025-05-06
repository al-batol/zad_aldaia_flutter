import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zad_aldaia/core/di/dependency_injection.dart';
import 'package:zad_aldaia/core/models/languge.dart';
import 'package:zad_aldaia/core/routing/routes.dart';
import 'package:zad_aldaia/features/add_article/logic/add_article_cubit.dart';
import 'package:zad_aldaia/features/add_article/ui/add_article_screen.dart';
import 'package:zad_aldaia/features/add_category/logic/add_category_cubit.dart';
import 'package:zad_aldaia/features/add_item/logic/add_item_cubit.dart';
import 'package:zad_aldaia/features/add_item/ui/add_item_screen.dart';
import 'package:zad_aldaia/features/admin/ui/admin_screen.dart';
import 'package:zad_aldaia/features/article/logic/article_cubit.dart';
import 'package:zad_aldaia/features/article/ui/article_screen.dart';
import 'package:zad_aldaia/features/categories/logic/categories_cubit.dart';
import 'package:zad_aldaia/features/categories/ui/categories_screen.dart';
import 'package:zad_aldaia/features/edit_item/logic/edit_item_cubit.dart';
import 'package:zad_aldaia/features/edit_item/ui/edit_item_screen.dart';
import 'package:zad_aldaia/features/home/logic/home_cubit.dart';
import 'package:zad_aldaia/features/home/ui/home_screen.dart';
import 'package:zad_aldaia/features/language/ui/language_screen.dart';
import 'package:zad_aldaia/features/search/logic/search_cubit.dart';
import 'package:zad_aldaia/features/search/ui/search_screen.dart';

import '../../features/add_category/ui/add_category_screen.dart';
import '../../features/role/role_selection.dart';

class AppRouter {
  Route? generateRoutes(RouteSettings settings) {
    final arguments = settings.arguments;

    switch (settings.name) {
      case MyRoutes.homeScreen:
        return MaterialPageRoute(
          builder:
              (context) => BlocProvider(
                create: (context) => getIt<HomeCubit>(),
                child: HomeScreen(),
              ),
        );  case MyRoutes.languageScreen:
        return MaterialPageRoute(
          builder:
              (context) => BlocProvider(
                create: (context) => getIt<HomeCubit>(),
                child: LanguageScreen(),
              ),
        );

      case MyRoutes.sectionsScreen:
        return MaterialPageRoute(
          builder:
              (context) => BlocProvider(
                create: (context) => getIt<CategoriesCubit>(),
                child: CategoriesScreen(
                  title: (arguments as Map)["title"],
                  section: arguments["section"],
                  language: arguments["language"],
                ),
              ),
        );
      case MyRoutes.articleScreen:
        return MaterialPageRoute(
          builder:
              (context) => BlocProvider(
                create: (context) => getIt<ArticleCubit>(),
                child: ArticleScreen(
                  section: (arguments as Map)["section"],
                  category: arguments["category"],
                  article: arguments["article"],
                  language: arguments["language"],
                ),
              ),
        );
      case MyRoutes.searchScreen:
        return MaterialPageRoute(
          builder:
              (context) => BlocProvider(
                create: (context) => getIt<SearchCubit>(),
                child: SearchScreen(),
              ),
        );
      case MyRoutes.adminScreen:
        return MaterialPageRoute(builder: (context) => AdminScreen());
      case MyRoutes.addCategoryScreen:
        return MaterialPageRoute(
          builder:
              (context) => BlocProvider(
                create: (context) => getIt<AddCategoryCubit>(),
                child: AddCategoryScreen(),
              ),
        );  case MyRoutes.roleSelectionScreen:
        return MaterialPageRoute(
          builder:
              (context) => BlocProvider(
                create: (context) => getIt<HomeCubit>(),
                child: RoleSelectionScreen(),
              ),
        );
      case MyRoutes.addArticleScreen:
        return MaterialPageRoute(
          builder:
              (context) => BlocProvider(
                create: (context) => getIt<AddArticleCubit>(),
                child: AddArticleScreen(),
              ),
        );
      case MyRoutes.addItemScreen:
        return MaterialPageRoute(
          builder:
              (context) => BlocProvider(
            create: (context) => getIt<AddItemCubit>(),
            child: AddItemScreen(),
          ),
        );
      case MyRoutes.editItemScreen:
        return MaterialPageRoute(
          builder:
              (context) => BlocProvider(
            create: (context) => getIt<EditItemCubit>(),
            child: EditItemScreen(),
          ),
        );

      default:
        return null;
    }
  }
}
