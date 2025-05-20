import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zad_aldaia/core/di/dependency_injection.dart';
import 'package:zad_aldaia/core/routing/routes.dart';
import 'package:zad_aldaia/features/admin/ui/admin_screen.dart';
import 'package:zad_aldaia/features/articles/ui/article_form_screen.dart';
import 'package:zad_aldaia/features/articles/ui/articles_screen.dart';
import 'package:zad_aldaia/features/categories/logic/categories_cubit.dart';
import 'package:zad_aldaia/features/categories/ui/categories_screen.dart';
import 'package:zad_aldaia/features/categories/ui/category_form_screen.dart';
import 'package:zad_aldaia/features/categories/ui/sections_screen.dart';
import 'package:zad_aldaia/features/items/ui/item_form_screen.dart';
import 'package:zad_aldaia/features/items/ui/items_screen.dart';
import 'package:zad_aldaia/features/search/logic/search_cubit.dart';
import 'package:zad_aldaia/features/search/ui/search_screen.dart';

class AppRouter {
  Route? generateRoutes(RouteSettings settings) {
    final arguments = settings.arguments as Map? ?? {};

    switch (settings.name) {
      case MyRoutes.homeScreen:
        return MaterialPageRoute(builder: (context) => SectionsScreen());
      case MyRoutes.categories:
        return MaterialPageRoute(
          builder: (context) => BlocProvider(create: (context) => getIt<CategoriesCubit>(), child: CategoriesScreen(title: arguments["title"], parentId: arguments["category_id"])),
        );
      case MyRoutes.searchScreen:
        return MaterialPageRoute(builder: (context) => BlocProvider(create: (context) => getIt<SearchCubit>(), child: SearchScreen()));
      case MyRoutes.adminScreen:
        return MaterialPageRoute(builder: (context) => AdminScreen());
      case MyRoutes.addCategoryScreen:
        return MaterialPageRoute(builder: (context) => CategoryFormScreen(categoryId: arguments["id"]));
      case MyRoutes.addArticleScreen:
        return MaterialPageRoute(builder: (context) => ArticleFormScreen(articleId: arguments["article_id"]));
      case MyRoutes.articles:
        return MaterialPageRoute(
          builder: (context) => BlocProvider(create: (context) => getIt<CategoriesCubit>(), child: ArticlesScreen(title: arguments["title"], categoryId: arguments["category_id"])),
        );
      case MyRoutes.articleScreen:
        return MaterialPageRoute(
          // builder: (context) => BlocProvider(create: (context) => getIt<ArticleCubit>(), child: ArticleScreen(id: arguments["id"], title: arguments["title"])),
          builder: (context) => ItemsScreen(articleId: arguments["id"], title: arguments["title"]),
        );
      case MyRoutes.addItemScreen:
        return MaterialPageRoute(builder: (context) => ItemFormScreen(itemId: arguments["id"], articleId: arguments["article_id"]));
      default:
        return null;
    }
  }
}
