import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zad_aldaia/core/routing/routes.dart';
import 'package:zad_aldaia/features/categories/logic/categories_cubit.dart';
import 'package:zad_aldaia/features/categories/ui/category_widget.dart';
import '../../../core/theming/my_text_style.dart';
import 'package:zad_aldaia/generated/l10n.dart';

class CategoriesScreen extends StatefulWidget {
  final String? parentId;
  final String? title;

  const CategoriesScreen({super.key, required this.parentId, this.title});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late CategoriesCubit cubit;
  bool _isSearching = false;

  @override
  void initState() {
    cubit = context.read<CategoriesCubit>();
    loadData();
    super.initState();
  }

  loadData() {
    cubit.loadCategories({'parent_id': widget.parentId}..removeWhere((key, value) => value == null));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (_isSearching) {
              setState(() {
                _isSearching = false;
              });
            } else {
              Navigator.of(context).pop();
            }
          },
          icon: Icon(Icons.arrow_back),
        ),
        titleTextStyle: MyTextStyle.font22primaryBold,
        title:
            _isSearching
                ? TextField(
                  autofocus: true,
                  decoration: InputDecoration(hintText: S.of(context).search, border: InputBorder.none),
                  style: const TextStyle(color: Colors.black),
                  onChanged: (query) {
                    // cubit.search(query);
                  },
                )
                : Text(widget.title ?? 'Categories'),
        actions: [
          _isSearching
              ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  _isSearching = false;
                  setState(() {});
                },
              )
              : IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  _isSearching = true;
                  setState(() {});
                },
              ),
          if (Supabase.instance.client.auth.currentUser != null)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).pushNamed(MyRoutes.addCategoryScreen, arguments: {"parent_id": widget.parentId});
              },
            ),
        ],
      ),
      body: SizedBox.expand(
        child: BlocBuilder<CategoriesCubit, CategoriesState>(
          builder: (context, state) {
            if (state is ListLoadedState) {
              if (state.items.isEmpty) {
                return Center(child: Text('Empty'));
              }
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: state.items.length,
                      itemBuilder: (context, index) {
                        final item = state.items[index];
                        return CategoryWidget(
                          category: item,
                          onTap: () {
                            if (item.childrenCount > 0) {
                              Navigator.of(context).pushNamed(MyRoutes.categories, arguments: {"category_id": item.id, "title": item.title});
                            } else {
                              Navigator.of(context).pushNamed(MyRoutes.articles, arguments: {"category_id": item.id, "title": item.title});
                            }
                          },
                          onArticleItemUp: (category) async {
                            if (index > 0) {
                              await cubit.swapCategoriesOrder(item.id, state.items[index - 1].id);
                              loadData();
                            }
                          },
                          onArticleItemDown: (category) async {
                            if (index < state.items.length - 1) {
                              await cubit.swapCategoriesOrder(item.id, state.items[index + 1].id);
                              loadData();
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }
}
