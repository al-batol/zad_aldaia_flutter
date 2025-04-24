import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zad_aldaia/core/widgets/my_text_form.dart';

import '../../../../generated/l10n.dart';

class TextItemLayout extends StatelessWidget {
  final TextEditingController itemTitleController;
  final TextEditingController itemContentController;
  final TextEditingController itemNoteController;
  const TextItemLayout({super.key, required this.itemTitleController, required this.itemContentController, required this.itemNoteController});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MyTextForm(
          controller: itemTitleController,
          validatorMessage: S.of(context).required,
          title: S.of(context).itemTitle,
        ),
        SizedBox(height: 10.h),
        MyTextForm(
          controller: itemContentController,
          validatorMessage: S.of(context).required,
          maxLines: 10,
          title: S.of(context).itemContent,
        ),
        SizedBox(height: 10.h),
        MyTextForm(
          controller: itemNoteController,
          title: S.of(context).itemNote,
        ),
      ],
    );
  }
}
