import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zad_aldaia/core/theming/my_colors.dart';
import 'package:zad_aldaia/core/theming/my_text_style.dart';

import '../../features/search/ui/highlighted_text.dart';

class NoteDialog extends StatelessWidget {
  final String? title;
  final String note;
  final String searchQuery;

  const NoteDialog({
    super.key,
    required this.note,
    this.title,
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 3,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            title != null
                ? HighlightedText(
              text: title!,
              query: searchQuery,
              style: MyTextStyle.font18BlackBold,
            )
                : Text("Note", style: MyTextStyle.font18BlackBold),
            SizedBox(height: 10.h),
            Flexible(
              child: SingleChildScrollView(
                child: HighlightedText(
                  text: note,
                  query: searchQuery,
                  style: MyTextStyle.font16BlackRegular,
                  selectable: true,
                  highlightStyle: TextStyle(
                    backgroundColor: MyColors.primaryColor.withOpacity(0.3),
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            MaterialButton(
              onPressed: () => Navigator.of(context).pop(),
              color: MyColors.primaryColor,
              child: Text("Dismiss", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}