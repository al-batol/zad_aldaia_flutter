import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zad_aldaia/core/theming/my_text_style.dart';
import 'package:zad_aldaia/features/categories/data/models/category.dart';

import '../../../add_article/data/models/article.dart';

class SectionItem extends StatelessWidget {
  final Category category;
  final Function(Article) onPressed;

  // final Widget? reorderIcon;

  const SectionItem({
    super.key,
    required this.category,
    required this.onPressed,
    // required this.reorderIcon,
  });

  @override
  Widget build(BuildContext context) {
    final ExpansionTileController controller = ExpansionTileController();
    return Container(
      margin: EdgeInsets.all(10),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        child: ExpansionTile(
          controller: controller,
          maintainState: true,
          // leading: const Icon(Icons.expand_more),
          // trailing: reorderIcon,
          title: SelectableText(
            onTap: () {
              controller.isExpanded
                  ? controller.collapse()
                  : controller.expand();
            },
            category.title,
            style: MyTextStyle.font18BlackRegular,
          ),
          expandedAlignment: Alignment.centerLeft,
          children: [
            ...List.generate(
              category.articles.length,
              (index) => Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: category.articles.length - 1 == index ? 10.h : 5.h,
                ),
                child: MaterialButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onPressed: () => onPressed(category.articles[index]),
                  elevation: 2,
                  color: Colors.grey.shade100,
                  child: SelectableText(
                    onTap: () {
                      onPressed(category.articles[index]);
                    },
                    category.articles[index].title,
                    style: MyTextStyle.font16BlackRegular,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
