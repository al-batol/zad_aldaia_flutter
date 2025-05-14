import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zad_aldaia/core/theming/my_text_style.dart';
import 'package:zad_aldaia/features/categories/data/models/category.dart';


class SectionItem extends StatelessWidget {
  final Category category;
  final Function(String) onPressed;

  const SectionItem({
    super.key,
    required this.category,
    required this.onPressed,
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
                  onPressed: () => onPressed(category.articles[index]),
                  elevation: 2,
                  //color:
                  child: SelectableText(
                    onTap: () {
                      onPressed(category.articles[index]);
                    },
                    category.articles[index],
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
