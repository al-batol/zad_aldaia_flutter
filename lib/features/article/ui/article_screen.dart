import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zad_aldaia/core/models/article_type.dart';
import 'package:zad_aldaia/core/theming/my_text_style.dart';
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
  final String article;

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

  @override
  void initState() {
    cubit = context.read<ArticleCubit>();
    cubit.getArticles(
      widget.section,
      widget.language,
      widget.category,
      widget.article,
    );
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
                : Text(widget.article),
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
                icon: Icon(const IconData(0xe802, fontFamily: "search_icon"),color: MyColors.primaryColor,),
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
              return ListView.builder(
                itemCount: state.items.length,
                itemBuilder: (context, index) {
                  var item = state.items[index];
                  switch (state.items[index].type) {
                    case ArticleType.Text:
                      return TextItem(item: item as TextArticle);
                    case ArticleType.Image:
                      return ImageItem(item: item as ImageArticle,onDownloadPressed: (url) async{
                        if(kIsWeb) {
                          await cubit.saveImageWeb(url);
                        }
                        else{
                          await cubit.saveImageAndroid(url);
                        }
                      },);
                    case ArticleType.Video:
                      return VideoItem(item: item as VideoArticle);
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
