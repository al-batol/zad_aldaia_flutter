import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zad_aldaia/core/di/dependency_injection.dart';
import 'package:zad_aldaia/core/helpers/share.dart';
import 'package:zad_aldaia/core/routing/routes.dart';
import 'package:zad_aldaia/core/theming/my_colors.dart';
import 'package:zad_aldaia/core/theming/my_text_style.dart';
import 'package:zad_aldaia/features/article/data/models/article_item.dart';
import 'package:flutter/services.dart';
import 'package:zad_aldaia/features/article/logic/article_cubit.dart';
import '../../../../core/widgets/note_dialog.dart';
import 'package:zad_aldaia/generated/l10n.dart';
import 'package:html_unescape/html_unescape.dart';

class TextItem extends StatefulWidget {
  final TextArticle item;
  final bool? isSelected;
  final Function(ArticleItem)? onSelect;

  final Function(ArticleItem)? onArticleItemUp;
  final Function(ArticleItem)? onArticleItemDown;

  const TextItem({
    super.key,
    required this.item,
    this.onSelect,
    this.isSelected = false,
    this.onArticleItemUp,
    this.onArticleItemDown,
  });

  @override
  State<TextItem> createState() => _TextItemState();
}

class _TextItemState extends State<TextItem> {
  late final Map<String, String> languageMap;
  late final ExpansionTileController _controller;

  late String content;
  bool isTranslating = false;

  @override
  void initState() {
    super.initState();
    content = widget.item.content;
    _controller = ExpansionTileController();
  }

  @override
  void didChangeDependencies() {
    languageMap = {
      S.of(context).original_text: "Original Text",
      S.of(context).english: "en",
      S.of(context).spanish: "es",
      S.of(context).chinese: "zh",
      S.of(context).hindi: "hi",
      S.of(context).arabic: "ar",
      S.of(context).french: "fr",
      S.of(context).bengali: "bn",
      S.of(context).russian: "ru",
      S.of(context).portuguese: "pt",
      S.of(context).urdu: "ur",
      S.of(context).german: "de",
      S.of(context).japanese: "ja",
      S.of(context).punjabi: "pa",
      S.of(context).telugu: "te",
    };
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(10),
        child: ExpansionTile(
          controller: _controller,
          expandedAlignment: Alignment.topLeft,
          title: SelectableText(
            onTap: () {
              _controller.isExpanded
                  ? _controller.collapse()
                  : _controller.expand();
            },
            widget.item.title,
            style: MyTextStyle.font18BlackBold,
          ),
          controlAffinity: ListTileControlAffinity.leading,
          tilePadding: EdgeInsets.symmetric(horizontal: 5.w),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.item.note.trim().isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 5.h,
                    horizontal: 10.w,
                  ),
                  child: InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => NoteDialog(note: widget.item.note),
                      );
                    },
                    child: Icon(
                      const IconData(0xe801, fontFamily: "pin_icon"),
                      color: MyColors.primaryColor,
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                child: InkWell(
                  onTap: () async {
                    await Clipboard.setData(
                      ClipboardData(text: widget.item.content),
                    ).then((value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(S.of(context).contentCopied)),
                      );
                    });
                  },
                  child: Icon(Icons.copy, color: MyColors.primaryColor),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                child:
                    isTranslating
                        ? Container(
                          width: 24.h,
                          height: 24.h,
                          child: CircularProgressIndicator(
                            color: MyColors.primaryColor,
                          ),
                        )
                        : PopupMenuButton<String>(
                          child: Icon(
                            Icons.g_translate,
                            color: MyColors.primaryColor,
                          ),
                          onSelected: (value) async {
                            setState(() {
                              isTranslating = true;
                            });
                            if (value == "Original Text") {
                              content = widget.item.content;
                            } else {
                              var translation = await getIt<ArticleCubit>()
                                  .translateText(widget.item.content, value);
                              if (translation != null) {
                                content = HtmlUnescape().convert(translation);
                              }
                            }
                            setState(() {
                              isTranslating = false;
                            });
                          },
                          itemBuilder: (BuildContext context) {
                            return languageMap.entries
                                .map(
                                  (e) => PopupMenuItem(
                                    value: e.value,
                                    child: Text(e.key),
                                  ),
                                )
                                .toList();
                          },
                        ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                child: InkWell(
                  onTap: () => Share.article(widget.item),
                  child: Icon(
                    Icons.share_outlined,
                    color: MyColors.primaryColor,
                  ),
                ),
              ),
              if (Supabase.instance.client.auth.currentUser != null)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.w),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        MyRoutes.editItemScreen,
                        arguments: {"id": widget.item.id},
                      );
                    },
                    child: Icon(Icons.edit, color: MyColors.primaryColor),
                  ),
                ),
              if (Supabase.instance.client.auth.currentUser != null)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.w),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () => widget.onArticleItemUp?.call(widget.item),
                        child: Icon(
                          Icons.arrow_circle_up,
                          color: MyColors.primaryColor,
                        ),
                      ),
                      InkWell(
                        onTap:
                            () => widget.onArticleItemDown?.call(widget.item),
                        child: Icon(
                          Icons.arrow_circle_down,
                          color: MyColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              if (widget.isSelected != null)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.w),
                  child: InkWell(
                    onTap: () => widget.onSelect?.call(widget.item),
                    child: Icon(
                      widget.isSelected!
                          ? Icons.check_box_outlined
                          : Icons.check_box_outline_blank,
                      color: MyColors.primaryColor,
                    ),
                  ),
                ),
            ],
          ),
          children: [
            Container(
              margin: EdgeInsets.all(10),
              child: SelectableText(
                content,
                style: MyTextStyle.font16BlackRegular,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
