import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zad_aldaia/core/routing/routes.dart';
import 'package:zad_aldaia/features/categories/logic/categories_cubit.dart';
import 'package:zad_aldaia/features/categories/logic/categories_state.dart';
import 'package:zad_aldaia/features/categories/ui/widgets/category_item.dart';
import '../../../core/theming/my_colors.dart';
import '../../../core/theming/my_text_style.dart';
import 'package:zad_aldaia/generated/l10n.dart';

import '../../../core/widgets/no_items_widget.dart';

class CategoriesScreen extends StatefulWidget {
  final String title;
  final String section;
  final String language;

  const CategoriesScreen({
    super.key,
    required this.title,
    required this.section,
    required this.language,
  });

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late CategoriesCubit cubit;
  bool _isSearching = false;

  @override
  void initState() {
    cubit = context.read<CategoriesCubit>();
    cubit.getCategories(widget.section, widget.language);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
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
                  decoration: InputDecoration(
                    hintText: S.of(context).search,
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(color: Colors.black),
                  onChanged: (query) {
                    cubit.search(query);
                  },
                )
                : Text(widget.title),
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
                icon: Icon(
                  const IconData(0xe802, fontFamily: "search_icon"),
                  color: MyColors.primaryColor,
                  size: 30.h,
                ),
                onPressed: () {
                  _isSearching = true;
                  setState(() {});
                },
              ),
        ],
      ),
      body: BlocBuilder<CategoriesCubit, CategoriesState>(
        builder: (context, state) {
          if (state is LoadedState) {
            if (state.categories.isEmpty) {
              return NoItemsWidget();
            }
            return ListView.builder(
              itemCount: state.categories.length,
              itemBuilder: (context, index) {
                return SectionItem(
                  category: state.categories[index],
                  onPressed: (String article) {
                    Navigator.of(context).pushNamed(
                      MyRoutes.articleScreen,
                      arguments: {
                        "category": state.categories[index].title,
                        "section": widget.section,
                        "article": article,
                        "language": widget.language,
                      },
                    );
                  },
                );
              },
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
