import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zad_aldaia/core/helpers/share.dart';
import 'package:zad_aldaia/core/helpers/translator.dart';
import 'package:zad_aldaia/core/routing/routes.dart';
import 'package:flutter/services.dart';
import 'package:zad_aldaia/features/items/data/models/item.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:zad_aldaia/generated/l10n.dart';

class TextItem extends StatefulWidget {
  final Item item;
  final bool? isSelected;
  final Function(Item)? onSelect;
  final Function(Item)? onItemUp;
  final Function(Item)? onItemDown;

  const TextItem({
    super.key, 
    required this.item, 
    this.onSelect, 
    this.isSelected, 
    this.onItemUp, 
    this.onItemDown
  });

  @override
  State<TextItem> createState() => _TextItemState();
}

class _TextItemState extends State<TextItem> {
  late String content;
  bool isTranslating = false;
  late Map<String, String> languageMap;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies(); 
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
  }

  @override
  void initState() {
    super.initState();
    content = widget.item.content ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      title: Text(
        widget.item.title ?? 'Text Content',
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF005A32),
        ),
      ),
      children: [
        Padding(
          padding: EdgeInsets.all(16.r),
          child: SelectableText(
            content,
            style: TextStyle(fontSize: 16.sp, height: 1.5),
          ),
        ),
        _buildActionBar(),
      ],
    );
  }

  Widget _buildActionBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.copy, color: const Color(0xFF005A32), size: 24.w),
                onPressed: _copyToClipboard,
              ),
              _buildTranslationButton(),
              IconButton(
                icon: Icon(Icons.share, color: const Color(0xFF005A32), size: 24.w),
                onPressed: () => Share.item(widget.item),
              ),
            ],
          ),
          Row(
            children: [
              if (Supabase.instance.client.auth.currentUser != null) ...[
                IconButton(
                  icon: Icon(Icons.arrow_upward, color: const Color(0xFF005A32), size: 24.w),
                  onPressed: () => widget.onItemUp?.call(widget.item),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_downward, color: const Color(0xFF005A32), size: 24.w),
                  onPressed: () => widget.onItemDown?.call(widget.item),
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: const Color(0xFF005A32), size: 24.w),
                  onPressed: () => Navigator.of(context).pushNamed(
                    MyRoutes.addItemScreen, 
                    arguments: {"id": widget.item.id}
                  ),
                ),
              ],
              if (widget.isSelected != null)
                IconButton(
                  icon: Icon(
                    widget.isSelected! ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: const Color(0xFF005A32),
                    size: 24.w,
                  ),
                  onPressed: () => widget.onSelect?.call(widget.item),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTranslationButton() {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.translate,
        color: isTranslating ? Colors.grey : const Color(0xFF005A32),
        size: 24.w,
      ),
      onSelected: _handleTranslation,
      itemBuilder: (context) => languageMap.entries.map((e) => 
        PopupMenuItem(
          value: e.value,
          child: Text(e.key, style: TextStyle(fontSize: 14.sp)),
        )
      ).toList(),
    );
  }

  void _handleTranslation(String lang) async {
    if (lang == "Original Text") {
      setState(() => content = widget.item.content ?? '');
      return;
    }

    setState(() => isTranslating = true);
    final translation = await Translator.text(widget.item.content, lang);
    if (translation != null) {
      setState(() => content = HtmlUnescape().convert(translation));
    }
    setState(() => isTranslating = false);
  }

  void _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Content copied to clipboard', style: TextStyle(fontSize: 14.sp))),
    );
  }
}