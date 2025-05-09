import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zad_aldaia/core/helpers/share.dart';
import 'package:zad_aldaia/core/models/article_type.dart';
import 'package:zad_aldaia/core/theming/my_text_style.dart';
import 'package:zad_aldaia/features/add_article/data/models/article.dart';
import 'package:zad_aldaia/features/article/data/models/article_item.dart';
import 'package:zad_aldaia/features/article/logic/article_cubit.dart';
import 'package:zad_aldaia/features/article/logic/article_state.dart';
import 'package:zad_aldaia/features/article/ui/widgets/image_item.dart';
import 'package:zad_aldaia/features/article/ui/widgets/text_item.dart';
import 'package:zad_aldaia/features/article/ui/widgets/video_item.dart';
import 'package:zad_aldaia/generated/l10n.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../core/theming/my_colors.dart';
import '../../../core/widgets/no_items_widget.dart';

class ArticleScreen extends StatefulWidget {
  final String section;
  final String language;
  final String category;
  final Article article;

  const ArticleScreen({
    super.key,
    required this.section,
    required this.language,
    required this.category,
    required this.article,
  });

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  late ArticleCubit cubit;
  bool _isSearching = false;
  List<ArticleItem> selectedItems = [];

  @override
  void initState() {
    cubit = context.read<ArticleCubit>();
    cubit.getArticles(
      widget.article.id ?? "",
      /*widget.section,
      widget.language,
      widget.category,
      widget.article.title,*/
    );
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
                    cubit.search(query);
                  },
                )
                : Text(widget.article.title),
        actions: [
          if (selectedItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                Share.multi(selectedItems);
              },
            ),
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
                ),
                onPressed: () {
                  _isSearching = true;
                  setState(() {});
                },
              ),
        ],
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        child: BlocBuilder<ArticleCubit, ArticleState>(
          builder: (context, state) {
            if (state is LoadedState) {
              if (state.items.isEmpty) {
                return NoItemsWidget();
              }
              return ReorderableListView.builder(
                itemCount: cubit.items.length,
                itemBuilder: (context, index) {
                  var item = cubit.items[index];
                  switch (cubit.items[index].type) {
                    case ArticleType.Text:
                      return TextItem(
                        key: ValueKey(item.id),
                        item: item as TextArticle,
                        reorderIcon: ReorderableDragStartListener(
                          index: index,
                          child: const Icon(
                            Icons.drag_indicator_outlined,
                            color: MyColors.primaryColor,
                          ),
                        ),
                        isSelected: selectedItems.contains(item),
                        onSelect: (article) {
                          if (selectedItems.contains(article)) {
                            selectedItems.remove(article);
                          } else {
                            selectedItems.add(article);
                          }
                          setState(() {});
                        },
                      );
                    case ArticleType.Image:
                      return ImageItem(
                        key: ValueKey(item.id),
                        item: item as ImageArticle,
                        onDownloadPressed: (url) async {
                          if (kIsWeb) {
                            await cubit.saveImageWeb(url);
                          } else {
                            await cubit.saveImageAndroid(url);
                          }
                        },
                        reorderIcon: ReorderableDragStartListener(
                          index: index,
                          child: const Icon(
                            Icons.drag_indicator_outlined,
                            color: MyColors.primaryColor,
                          ),
                        ),
                        isSelected: selectedItems.contains(item),
                        onSelect: (article) {
                          if (selectedItems.contains(article)) {
                            selectedItems.remove(article);
                          } else {
                            selectedItems.add(article);
                          }
                          setState(() {});
                        },
                      );
                    case ArticleType.Video:
                      return VideoItem(
                        key: ValueKey(item.id),
                        item: item as VideoArticle,
                        reorderIcon: ReorderableDragStartListener(
                          index: index,
                          child: const Icon(
                            Icons.drag_indicator_outlined,
                            color: MyColors.primaryColor,
                          ),
                        ),
                        isSelected: selectedItems.contains(item),
                        onSelect: (article) {
                          if (selectedItems.contains(article)) {
                            selectedItems.remove(article);
                          } else {
                            selectedItems.add(article);
                          }
                          setState(() {});
                        },
                      );
                  }
                },
                onReorder: (int oldIndex, int newIndex) {
                  print("oldIndex: $oldIndex, newIndex: $newIndex");
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                    final item = cubit.items[oldIndex];
                    // cubit.updateArticleOrder(item.id, newIndex);
                    cubit.updateArticleItem(
                      articleId: widget.article.id ?? "",
                      itemId: item.id,
                      newOrder: newIndex,
                    );
                  }
                },
              );
            }
            return Container();
          },
        ),
      ),
    );
  }
}
