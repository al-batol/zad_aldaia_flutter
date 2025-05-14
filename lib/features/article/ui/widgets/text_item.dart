import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import '../../../search/logic/search_cubit.dart';
import '../../../search/logic/search_state.dart';
import '../../../search/ui/highlighted_text.dart';

class TextItem extends StatefulWidget {
  final TextArticle item;
  final bool? isSelected;
  final Function(ArticleItem)? onSelect;

  const TextItem({
    super.key,
    required this.item,
    this.onSelect,
    this.isSelected = false,
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkForAutoExpand();
    });

    super.didChangeDependencies();
  }

  String get searchQuery {
    final state = context.read<SearchCubit>().state;
    if (state is SearchLoadedState) {
      return state.query;
    }
    return '';
  }

  void checkForAutoExpand() {
    final query = searchQuery;
    if (query.isNotEmpty) {
      final bool matchInContent = content.toLowerCase().contains(
        query.toLowerCase(),
      );
      final bool matchInNote = widget.item.note.toLowerCase().contains(
        query.toLowerCase(),
      );
      if ((matchInContent || matchInNote) && !_controller.isExpanded) {
        _controller.expand();
      }
    }
  }

  bool hasHiddenMatch() {
    final query = searchQuery;
    if (query.isEmpty) return false;
    final bool matchInTitle = widget.item.title.toLowerCase().contains(
      query.toLowerCase(),
    );
    final bool matchInContent = content.toLowerCase().contains(
      query.toLowerCase(),
    );
    final bool matchInNote = widget.item.note.toLowerCase().contains(
      query.toLowerCase(),
    );

    return (matchInContent || matchInNote) && !matchInTitle;
  }

  bool hasMatchInNote() {
    final query = searchQuery;
    if (query.isEmpty) return false;
    return widget.item.note.toLowerCase().contains(query.toLowerCase());
  }

  Color parseBackgroundColor(String? rawColor) {
    try {
      if (rawColor == null ||
          rawColor.trim().isEmpty ||
          rawColor.trim().toLowerCase() == "Null") {
        return const Color(0xFFFFFFFF);
      }
      final cleaned = rawColor.trim().replaceAll("#", "");
      print("🎨 Cleaned color: $cleaned");

      if (cleaned.length == 6 &&
          RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(cleaned)) {
        final parsed = Color(int.parse('0xFF$cleaned'));
        print("✅ Parsed color: $parsed");
        return parsed;
      }
    } catch (e) {
      print("❌ Color parsing failed: $e");
    }
    print("❌ Fallback to white");
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final bool hiddenMatch = hasHiddenMatch();
    final bool noteMatch = hasMatchInNote();

    final backgroundColor = parseBackgroundColor(widget.item.backgroundColor);
    if (kDebugMode) {
      print(backgroundColor);
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
            border:
                hiddenMatch
                    ? Border.all(color: Colors.yellow, width: 2.0)
                    : null,
          ),
          child: ExpansionTile(
            controller: _controller,
            expandedAlignment: Alignment.topLeft,
            title: HighlightedText(
              text: widget.item.title,
              query: searchQuery,
              style: MyTextStyle.font18BlackBold,
              selectable: true,
              highlightStyle: TextStyle(
                backgroundColor: Colors.yellow,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              onTap: () {
                _controller.isExpanded
                    ? _controller.collapse()
                    : _controller.expand();
              },
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
                    child: Stack(
                      children: [
                        InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder:
                                  (context) => NoteDialog(
                                    note: widget.item.note,
                                    searchQuery: searchQuery,
                                  ),
                            );
                          },
                          child: Icon(
                            const IconData(0xe801, fontFamily: "pin_icon"),
                            color:
                                noteMatch
                                    ? Colors.yellow[700]
                                    : MyColors.primaryColor,
                          ),
                        ),
                        if (noteMatch)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.yellow,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                      ],
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
                          ? SizedBox(
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
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                checkForAutoExpand();
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
                child: HighlightedText(
                  text: content,
                  query: searchQuery,
                  style: MyTextStyle.font16BlackRegular,
                  selectable: true,
                  highlightStyle: TextStyle(
                    backgroundColor: Colors.yellow,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
