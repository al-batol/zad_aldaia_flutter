import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zad_aldaia/core/routing/routes.dart';
import 'package:zad_aldaia/features/categories/data/models/category.dart';
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
                    // cubit.search(query);
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
      body: SizedBox.expand(
        child: BlocBuilder<CategoriesCubit, CategoriesState>(
          builder: (context, state) {
            if (state is LoadedState) {
              if (state.categories.isEmpty) {
                return Column(
                  children: [
                    NoItemsWidget(),
                    const SizedBox(height: 20),
                    Supabase.instance.client.auth.currentUser != null
                        ? ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              MyColors.primaryColor,
                            ),
                            padding: MaterialStateProperty.all(
                              EdgeInsets.symmetric(
                                vertical: 10.h,
                                horizontal: 20.w,
                              ),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              MyRoutes.addCategoryScreen,
                              arguments: {
                                "section": widget.section,
                                "language": widget.language,
                              },
                            );
                          },
                          child: Text(
                            "Add Category",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                            ),
                          ),
                        )
                        : SizedBox(),
                  ],
                );
              }
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      physics:
                          const AlwaysScrollableScrollPhysics(), // تأكد من التمرير
                      shrinkWrap: true,
                      itemCount: state.categories.length + 1,
                      itemBuilder: (context, index) {
                        /*print('length ${state.categories[index].id}');
                        print('length ${state.categories[index].title}');
                        print('length ${state.categories[index].order}');*/
                        if (index == state.categories.length) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child:
                                Supabase.instance.client.auth.currentUser !=
                                        null
                                    ? ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                              MyColors.primaryColor,
                                            ),
                                        padding: MaterialStateProperty.all(
                                          EdgeInsets.symmetric(
                                            vertical: 10.h,
                                            horizontal: 20.w,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pushNamed(
                                          MyRoutes.addCategoryScreen,
                                          arguments: {
                                            "section": widget.section,
                                            "language": widget.language,
                                          },
                                        );
                                      },
                                      child: Text(
                                        "Add Category",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.sp,
                                        ),
                                      ),
                                    )
                                    : null,
                          );
                        }
                        return SectionItem(
                          key: Key(state.categories[index].id),
                          onArticleItemUp: (category) {
                            if (index > 0) {
                              cubit.swapCategoriesOrder(
                                state.categories[index].id,
                                state.categories[index - 1].id,
                                widget.section,
                                widget.language,
                              );
                            }
                          },
                          onArticleItemDown: (category) {
                            if (index < state.categories.length - 1) {
                              cubit.swapCategoriesOrder(
                                state.categories[index].id,
                                state.categories[index + 1].id,
                                widget.section,
                                widget.language,
                              );
                            }
                          },
                          category: state.categories[index],
                          onPressed: (Article article) {
                            print('length ${state.categories.length}');
                            Navigator.of(context).pushNamed(
                              MyRoutes.articleScreen,
                              arguments: {
                                "category": state.categories[index].title,
                                "section": widget.section,
                                "article": article.title ?? '',
                                "language": widget.language,
                              },
                            );
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
