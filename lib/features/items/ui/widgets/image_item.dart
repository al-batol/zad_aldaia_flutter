import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zad_aldaia/core/helpers/share.dart';
import 'package:zad_aldaia/core/routing/routes.dart';
import 'package:zad_aldaia/features/items/data/models/item.dart';

class ImageItem extends StatefulWidget {
  final Item item;
  final bool? isSelected;
  final Function(Item)? onSelect;
  final Function(Item)? onItemUp;
  final Function(Item)? onItemDown;
  final Future Function(String) onDownloadPressed;

  const ImageItem({
    super.key, 
    required this.item, 
    required this.onDownloadPressed, 
    this.onSelect, 
    this.isSelected, 
    this.onItemUp, 
    this.onItemDown
  });

  @override
  State<ImageItem> createState() => _ImageItemState();
}

class _ImageItemState extends State<ImageItem> {
  bool isDownloading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          title: Text(
            widget.item.title ?? 'Image',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF005A32),
            ),
          ),
          children: [
            Padding(
              padding: EdgeInsets.all(16.r),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: CachedNetworkImage(
                  imageUrl: widget.item.imageUrl ?? '',
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error, size: 24.w),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            _buildActionBar(),
          ],
        ),
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
                icon: isDownloading 
                  ? SizedBox(
                      width: 24.w,
                      height: 24.h,
                      child: CircularProgressIndicator(),
                    )
                  : Icon(Icons.download, color: const Color(0xFF005A32), size: 24.w),
                onPressed: isDownloading ? null : _downloadImage,
              ),
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

  Future<void> _downloadImage() async {
    setState(() => isDownloading = true);
    try {
      await widget.onDownloadPressed(widget.item.imageUrl ?? '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image downloaded successfully', style: TextStyle(fontSize: 14.sp))),
      );
    } finally {
      setState(() => isDownloading = false);
    }
  }
}