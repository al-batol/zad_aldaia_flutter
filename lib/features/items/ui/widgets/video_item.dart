import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:zad_aldaia/core/helpers/share.dart';
import 'package:zad_aldaia/core/routing/routes.dart';
import 'package:zad_aldaia/features/items/data/models/item.dart';

import '../../../../core/theming/my_colors.dart';
import '../../../../core/widgets/note_dialog.dart';

class VideoItem extends StatefulWidget {
  final Item item;
  final bool? isSelected;
  final Function(Item)? onItemUp;
  final Function(Item)? onItemDown;
  final Function(Item)? onSelect;

  const VideoItem({super.key, required this.item, this.onSelect, this.isSelected = false, this.onItemUp, this.onItemDown});

  @override
  State<VideoItem> createState() => _YoutubePlayerWidgetState();
}

class _YoutubePlayerWidgetState extends State<VideoItem> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    final videoId = YoutubePlayer.convertUrlToId(widget.item.youtubeUrl!)!;

    _controller = YoutubePlayerController(initialVideoId: videoId, flags: const YoutubePlayerFlags(autoPlay: false, mute: false, forceHD: false));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Colors.redAccent,
            bottomActions: const [
              SizedBox(width: 14),
              CurrentPosition(),
              SizedBox(width: 8),
              ProgressBar(isExpanded: true, colors: ProgressBarColors(playedColor: Colors.redAccent, handleColor: Colors.redAccent, backgroundColor: Colors.grey)),
              RemainingDuration(),
              PlaybackSpeedButton(),
            ],
          ),
        ),
        Column(
          children: [
            if (widget.item.note?.trim().isNotEmpty ?? false)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
                child: InkWell(
                  onTap: () {
                    showDialog(context: context, builder: (context) => NoteDialog(note: widget.item.note!));
                  },
                  child: Icon(const IconData(0xe801, fontFamily: "pin_icon"), color: MyColors.primaryColor),
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
      ],
    );
  }
}
