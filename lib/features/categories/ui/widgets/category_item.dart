import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zad_aldaia/core/theming/my_text_style.dart';
import 'package:zad_aldaia/features/categories/data/models/category.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theming/my_colors.dart';

class SectionItem extends StatelessWidget {
  final Category category;
  final Function(Article) onPressed;
  final Function(Category)? onArticleItemUp;
  final Function(Category)? onArticleItemDown;

  const SectionItem({
    super.key,
    required this.category,
    required this.onPressed,
    this.onArticleItemUp,
    this.onArticleItemDown,
  });

  @override
  Widget build(BuildContext context) {
    print('category: ${category.title}');
    var articles = category.articles ?? [];
    final ExpansionTileController controller = ExpansionTileController();
    return Container(
      margin: EdgeInsets.all(10),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          controller: controller,
          leading: Icon(
            Icons.keyboard_arrow_down_outlined,
            color: MyColors.primaryColor,
          ),
          trailing: Column(
            children: [
              if (Supabase.instance.client.auth.currentUser != null)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.w),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () => onArticleItemUp?.call(category),
                        child: Icon(
                          Icons.arrow_circle_up,
                          color: MyColors.primaryColor,
                        ),
                      ),
                      InkWell(
                        onTap: () => onArticleItemDown?.call(category),
                        child: Icon(
                          Icons.arrow_circle_down,
                          color: MyColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
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
            articles.isEmpty
                ? Container()
                : ListView.builder(
                  shrinkWrap: true,
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () => onPressed(articles[index]),
                      child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: articles.length - 1 == index ? 10.h : 5.h,
                        ),
                        child: MaterialButton(
                          onPressed: () => onPressed(articles[index]),
                          elevation: 2,
                          color: Colors.grey.shade100,
                          child: SelectableText(
                            onTap: () {
                              onPressed(articles[index]);
                            },
                            articles[index].title,
                            style: MyTextStyle.font16BlackRegular,
                          ),
                        ),
                      ),
                    );
                  },
                ),
            SizedBox(height: 10.h),
            if (Supabase.instance.client.auth.currentUser != null)
              Center(
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      MyColors.primaryColor,
                    ),
                    padding: MaterialStateProperty.all(
                      EdgeInsets.symmetric(vertical: 10.h, horizontal: 40.w),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      MyRoutes.addArticleScreen,
                      arguments: {
                        "category": category.title,
                        "section": category.section,
                        "language": category.language,
                      },
                    );
                  },
                  child: Text(
                    "Add Article",
                    style: TextStyle(color: Colors.white, fontSize: 16.sp),
                  ),
                ),
              ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }
}
