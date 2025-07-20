import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:zad_aldaia/core/helpers/share.dart';
import 'package:zad_aldaia/core/routing/routes.dart';
import 'package:zad_aldaia/features/items/data/models/item.dart';

class VideoItem extends StatefulWidget {
  final Item item;
  final bool? isSelected;
  final Function(Item)? onSelect;
  final Function(Item)? onItemUp;
  final Function(Item)? onItemDown;

  const VideoItem({
    super.key, 
    required this.item, 
    this.onSelect, 
    this.isSelected, 
    this.onItemUp, 
    this.onItemDown
  });

  @override
  State<VideoItem> createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayer.convertUrlToId(widget.item.youtubeUrl ?? '') ?? '';
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          title: Text(
            'Video',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF005A32)),
          ),
          children: [
            Padding(
              padding: EdgeInsets.all(16.r),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: YoutubePlayer(
                  controller: _controller,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: const Color(0xFF005A32),
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
          IconButton(
            icon: Icon(Icons.share, color: const Color(0xFF005A32), size: 24.w),
            onPressed: () => Share.item(widget.item),
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
}