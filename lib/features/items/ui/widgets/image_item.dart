import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zad_aldaia/core/helpers/share.dart';
import 'package:zad_aldaia/core/routing/routes.dart';
import 'package:zad_aldaia/features/items/data/models/item.dart';
import 'package:zad_aldaia/generated/l10n.dart';
import '../../../../core/theming/my_colors.dart';
import '../../../../core/widgets/note_dialog.dart';

class ImageItem extends StatefulWidget {
  final Item item;
  final bool? isSelected;
  final Function(Item)? onSelect;
  final Function(Item)? onItemUp;
  final Function(Item)? onItemDown;
  final Future Function(String) onDownloadPressed;

  const ImageItem({super.key, required this.item, required this.onDownloadPressed, this.onSelect, this.isSelected, this.onItemUp, this.onItemDown});

  @override
  State<ImageItem> createState() => _ImageItemState();
}

class _ImageItemState extends State<ImageItem> {
  bool isDownloading = false;
  final ExpansionTileController _controller = ExpansionTileController();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
      child: Material(
        elevation: 2,
        child: ExpansionTile(
          controller: _controller,
          expandedAlignment: Alignment.topLeft,
          title: SelectableText(
            onTap: () {
              _controller.isExpanded ? _controller.collapse() : _controller.expand();
            },
            'Image',
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.item.note?.trim().isNotEmpty ?? false)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
                  child: InkWell(
                    onTap: () {
                      showDialog(context: context, builder: (context) => NoteDialog(note: widget.item.note ?? '---'));
                    },
                    child: Icon(const IconData(0xe801, fontFamily: "pin_icon"), color: MyColors.primaryColor),
                  ),
                ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
                child:
                    isDownloading
                        ? SizedBox(width: 24.h, height: 24.h, child: CircularProgressIndicator(color: MyColors.primaryColor))
                        : InkWell(
                          onTap: () async {
                            setState(() {
                              isDownloading = true;
                            });
                            await widget.onDownloadPressed(widget.item.imageUrl ?? '---');
                            setState(() {
                              isDownloading = false;
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.of(context).imageDownloaded)));
                            });
                          },
                          child: Icon(Icons.download, color: MyColors.primaryColor),
                        ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                child: InkWell(onTap: () => Share.item(widget.item), child: Icon(Icons.share_outlined, color: MyColors.primaryColor)),
              ),
              if (Supabase.instance.client.auth.currentUser != null)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed(MyRoutes.addItemScreen, arguments: {"id": widget.item.id});
                    },
                    child: Icon(Icons.edit, color: MyColors.primaryColor),
                  ),
                ),
              if (Supabase.instance.client.auth.currentUser != null)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.w),
                  child: Column(
                    children: [
                      InkWell(onTap: () => widget.onItemUp?.call(widget.item), child: Icon(Icons.arrow_circle_up, color: MyColors.primaryColor)),
                      InkWell(onTap: () => widget.onItemDown?.call(widget.item), child: Icon(Icons.arrow_circle_down, color: MyColors.primaryColor)),
                    ],
                  ),
                ),
              if (widget.isSelected != null)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.w),
                  child: InkWell(
                    onTap: () => widget.onSelect?.call(widget.item),
                    child: Icon(widget.isSelected! ? Icons.check_box_outlined : Icons.check_box_outline_blank, color: MyColors.primaryColor),
                  ),
                ),
            ],
          ),
          controlAffinity: ListTileControlAffinity.leading,
          tilePadding: EdgeInsets.symmetric(horizontal: 5.w),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: widget.item.imageUrl ?? '---',
                  errorWidget: (context, url, error) => Icon(Icons.error),
                  progressIndicatorBuilder:
                      (context, url, downloadProgress) => Center(
                        child: SizedBox(
                          width: 50.h,
                          height: 50.h,
                          child: CircularProgressIndicator(color: MyColors.primaryColor, strokeWidth: 4, value: downloadProgress.progress),
                        ),
                      ),
                  fit: BoxFit.cover,
                  height: 400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
