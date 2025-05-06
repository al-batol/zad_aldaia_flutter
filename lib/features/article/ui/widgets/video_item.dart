import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:zad_aldaia/features/article/data/models/article_item.dart';
import 'package:zad_aldaia/generated/l10n.dart';

import '../../../../core/theming/my_colors.dart';
import '../../../../core/widgets/note_dialog.dart';

class VideoItem extends StatefulWidget {
  final VideoArticle item;

  const VideoItem({super.key, required this.item});

  @override
  State<VideoItem> createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    final videoId = YoutubePlayerController.convertUrlToId(widget.item.videoId);
    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId!,
      autoPlay: false,
      params: YoutubePlayerParams(
        mute: false,
        showControls: true,
        showFullscreenButton: false,
      ),
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: YoutubePlayer(controller: _controller)),
              Column(
                children: [
                  if (widget.item.note.isNotEmpty)
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
                    padding: EdgeInsets.symmetric(
                      vertical: 5.h,
                      horizontal: 10.w,
                    ),
                    child: InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder:
                              (context) => NoteDialog(
                                note: widget.item.id,
                                title: S.of(context).itemId,
                              ),
                        );
                      },
                      child: Icon(
                        Icons.info_outline,
                        color: MyColors.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
