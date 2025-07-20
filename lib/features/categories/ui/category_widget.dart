import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zad_aldaia/core/routing/routes.dart';
import 'package:zad_aldaia/features/categories/data/models/category.dart';

class CategoryWidget extends StatelessWidget {
  final Category category;
  final VoidCallback? onTap;
  final Function(Category)? onMoveUp;
  final Function(Category)? onMoveDown;

  const CategoryWidget({
    super.key,
    required this.category,
    this.onTap,
    this.onMoveUp,
    this.onMoveDown,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: category.isActive ? 1.0 : 0.5,
      child: Card(
        elevation: 2.0,
        child: ListTile(
          onTap: onTap,
          leading: (category.image == null)
              ? null
              : CachedNetworkImage(
                  imageUrl: category.image!,
                  height: 50.h,
                  width: 50.w,
                  fit: BoxFit.cover,
                ),
          title: Text(
            category.title ?? '---',
            style: TextStyle(fontSize: 16.sp),
          ),
          subtitle: Text(
            category.lang ?? '',
            style: TextStyle(fontSize: 14.sp),
          ),
          trailing: (Supabase.instance.client.auth.currentUser == null)
              ? null
              : SizedBox(
                  width: 80.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: Colors.amber,
                          size: 24.w,
                        ),
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                            MyRoutes.addCategoryScreen,
                            arguments: {"id": category.id},
                          );
                        },
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () => onMoveUp?.call(category),
                            child: Icon(
                              Icons.arrow_circle_up,
                              size: 24.w,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          InkWell(
                            onTap: () => onMoveDown?.call(category),
                            child: Icon(
                              Icons.arrow_circle_down,
                              size: 24.w,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}