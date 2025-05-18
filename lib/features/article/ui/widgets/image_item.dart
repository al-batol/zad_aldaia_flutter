import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zad_aldaia/core/helpers/share.dart';
import 'package:zad_aldaia/core/routing/routes.dart';
import 'package:zad_aldaia/features/article/data/models/article_item.dart';
import 'package:zad_aldaia/generated/l10n.dart';
import '../../../../core/theming/my_colors.dart';
import '../../../../core/theming/my_text_style.dart';
import '../../../../core/widgets/note_dialog.dart';

class ImageItem extends StatefulWidget {
  final ImageArticle item;
  final bool? isSelected;
  final Function(ArticleItem)? onSelect;
  final Function(ArticleItem)? onArticleItemUp; // From update-order-of-items
  final Function(ArticleItem)? onArticleItemDown; // From update-order-of-items
  final Future Function(String) onDownloadPressed;

  const ImageItem({
    super.key,
    required this.item,
    required this.onDownloadPressed,
    this.onSelect,
    this.isSelected = false,
    this.onArticleItemUp, // From update-order-of-items
    this.onArticleItemDown, // From update-order-of-items
  });

  @override
  State<ImageItem> createState() => _ImageItemState();
}

class _ImageItemState extends State<ImageItem> {
  bool isDownloading = false;
  late final ExpansionTileController _controller;

  @override
  void initState() {
    super.initState(); // Call super.initState() first
    _controller = ExpansionTileController();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(10),
        child: Container( // Retaining container for potential future background styling
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white, // Default color from test-merge
          ),
          child: ExpansionTile(
            controller: _controller,
            expandedAlignment: Alignment.topLeft,
            tilePadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h), // Adjusted vertical padding
            title: Text(
              // Use item.title if available and not empty, otherwise note, then fallback
              widget.item.title.isNotEmpty ? widget.item.title : (widget.item.note.isNotEmpty ? widget.item.note : S.of(context).image),
              style: MyTextStyle.font18BlackBold,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            // --- Trailing icons: Reorder and Selection ---
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Reorder icons from update-order-of-items
                if (Supabase.instance.client.auth.currentUser != null &&
                    widget.onArticleItemUp != null &&
                    widget.onArticleItemDown != null)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () => widget.onArticleItemUp?.call(widget.item),
                        child: Icon(
                          Icons.arrow_circle_up,
                          color: MyColors.primaryColor,
                          size: 20.sp, // Adjust size as needed
                        ),
                      ),
                      InkWell(
                        onTap: () => widget.onArticleItemDown?.call(widget.item),
                        child: Icon(
                          Icons.arrow_circle_down,
                          color: MyColors.primaryColor,
                          size: 20.sp, // Adjust size as needed
                        ),
                      ),
                    ],
                  ),
                if (Supabase.instance.client.auth.currentUser != null &&
                    widget.onArticleItemUp != null &&
                    widget.onArticleItemDown != null)
                  SizedBox(width: 8.w), // Spacer

                // Select icon (common)
                if (widget.isSelected != null)
                  InkWell(
                    onTap: () => widget.onSelect?.call(widget.item),
                    child: Icon(
                      widget.isSelected!
                          ? Icons.check_box_outlined
                          : Icons.check_box_outline_blank,
                      color: MyColors.primaryColor,
                      size: 24.sp, // Adjust size as needed
                    ),
                  ),
              ],
            ),
            childrenPadding: EdgeInsets.zero, // From test-merge
            children: [
              ClipRRect(
                // Using ClipRRect from test-merge to ensure image corners are rounded if needed
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                child: CachedNetworkImage(
                  imageUrl: widget.item.url,
                  errorWidget: (context, url, error) => Icon(Icons.error, size: 50.sp),
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      Center(
                        child: SizedBox(
                          width: 50.h,
                          height: 50.h,
                          child: CircularProgressIndicator(
                            color: MyColors.primaryColor,
                            strokeWidth: 4,
                            value: downloadProgress.progress,
                          ),
                        ),
                      ),
                  fit: BoxFit.cover,
                  width: double.infinity, // Take full width
                  height: 250.h, // Adjusted height
                ),
              ),
              // --- Action buttons below the image (when expanded) ---
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Note Icon (common logic)
                    if (widget.item.note.trim().isNotEmpty)
                      InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => NoteDialog(note: widget.item.note),
                          );
                        },
                        child: Tooltip(
                          message: S.of(context).viewNote,
                          child: Icon(
                            const IconData(0xe801, fontFamily: "pin_icon"),
                            color: MyColors.primaryColor,
                          ),
                        ),
                      ),
                    // Download Icon (common logic)
                    isDownloading
                        ? SizedBox(
                            width: 24.w, // Use .w for width
                            height: 24.h,
                            child: CircularProgressIndicator(
                              color: MyColors.primaryColor,
                            ),
                          )
                        : InkWell(
                            onTap: () async {
                              setState(() {
                                isDownloading = true;
                              });
                              await widget.onDownloadPressed(widget.item.url);
                              if (mounted) { // Check if widget is still in the tree
                                setState(() {
                                  isDownloading = false;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(S.of(context).imageDownloaded)),
                                );
                              }
                            },
                            child: Tooltip(
                              message: S.of(context).downloadImage,
                              child: Icon(Icons.download, color: MyColors.primaryColor),
                            ),
                          ),
                    // Share Icon (common)
                    InkWell(
                      onTap: () => Share.article(widget.item),
                      child: Tooltip(
                        message: S.of(context).share,
                        child: Icon(
                          Icons.share_outlined,
                          color: MyColors.primaryColor,
                        ),
                      ),
                    ),
                    // Edit Icon (common, if user is logged in)
                    if (Supabase.instance.client.auth.currentUser != null)
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            MyRoutes.editItemScreen,
                            arguments: {"id": widget.item.id},
                          );
                        },
                        child: Tooltip(
                          message: S.of(context).edit,
                          child: Icon(Icons.edit, color: MyColors.primaryColor),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}