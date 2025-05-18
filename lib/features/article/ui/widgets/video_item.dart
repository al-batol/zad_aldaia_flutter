import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:zad_aldaia/core/helpers/share.dart';
import 'package:zad_aldaia/core/routing/routes.dart';
import 'package:zad_aldaia/features/article/data/models/article_item.dart';
import 'package:zad_aldaia/generated/l10n.dart';

import '../../../../core/theming/my_colors.dart';
import '../../../../core/theming/my_text_style.dart';
import '../../../../core/widgets/note_dialog.dart';

class VideoItem extends StatefulWidget {
  final VideoArticle item;
  final bool? isSelected;
  final Function(ArticleItem)? onSelect;

  const VideoItem({super.key, required this.item, this.onSelect, this.isSelected = false});

  @override
  State<VideoItem> createState() => _YoutubePlayerWidgetState();
}

class _YoutubePlayerWidgetState extends State<VideoItem> {
  late YoutubePlayerController _controller;
  late final ExpansionTileController _expansionController;

  @override
  void initState() {
    super.initState();
    _expansionController = ExpansionTileController();
    _initializePlayer();
  }

  void _initializePlayer() {
    final videoId = YoutubePlayer.convertUrlToId(widget.item.videoId)!;
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        forceHD: false,
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
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: ExpansionTile(
            controller: _expansionController,
            expandedAlignment: Alignment.topLeft,
            tilePadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
            title: Text(
              widget.item.note ?? 'Video',
              style: MyTextStyle.font18BlackBold,
            ),
            trailing: const SizedBox.shrink(),
            children: [
              YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
                progressIndicatorColor: Colors.redAccent,
                bottomActions: const [
                  SizedBox(width: 14),
                  CurrentPosition(),
                  SizedBox(width: 8),
                  ProgressBar(
                    isExpanded: true,
                    colors: ProgressBarColors(
                      playedColor: Colors.redAccent,
                      handleColor: Colors.redAccent,
                      backgroundColor: Colors.grey,
                    ),
                  ),
                  RemainingDuration(),
                  PlaybackSpeedButton(),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (widget.item.note.trim().isNotEmpty)
                      InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => NoteDialog(note: widget.item.note),
                          );
                        },
                        child: Icon(
                          const IconData(0xe801, fontFamily: "pin_icon"),
                          color: MyColors.primaryColor,
                        ),
                      ),
                    InkWell(
                      onTap: () => Share.article(widget.item),
                      child: Icon(Icons.share_outlined, color: MyColors.primaryColor),
                    ),
                    if (Supabase.instance.client.auth.currentUser != null)
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            MyRoutes.editItemScreen,
                            arguments: {"id": widget.item.id},
                          );
                        },
                        child: Icon(Icons.edit, color: MyColors.primaryColor),
                      ),
                    if (widget.isSelected != null)
                      InkWell(
                        onTap: () => widget.onSelect?.call(widget.item),
                        child: Icon(
                          widget.isSelected!
                              ? Icons.check_box_outlined
                              : Icons.check_box_outline_blank,
                          color: MyColors.primaryColor,
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
