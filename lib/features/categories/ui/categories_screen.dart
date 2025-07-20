import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zad_aldaia/core/routing/routes.dart';
import 'package:zad_aldaia/core/theming/my_text_style.dart';
import 'package:zad_aldaia/features/categories/data/models/category.dart';
import 'package:zad_aldaia/features/categories/logic/categories_cubit.dart';

class CategoriesScreen extends StatefulWidget {
  final String? parentId;
  final String? title;

  const CategoriesScreen({super.key, required this.parentId, this.title});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late CategoriesCubit cubit;

  @override
  void initState() {
    cubit = context.read<CategoriesCubit>();
    loadData();
    super.initState();
  }

  void loadData() {
    cubit.loadCategories({'parent_id': widget.parentId}..removeWhere((key, value) => value == null));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FAE6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF005A32),
        titleTextStyle: MyTextStyle.font16WhiteBold,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(widget.title ?? 'Categories'),
        actions: [
          if (Supabase.instance.client.auth.currentUser != null)
            IconButton(
              icon: Icon(Icons.add, color: Colors.white, size: 24.w),
              onPressed: () {
                Navigator.of(context).pushNamed(
                  MyRoutes.addCategoryScreen,
                  arguments: {"parent_id": widget.parentId},
                );
              },
            ),
        ],
      ),
      body: SizedBox.expand(
        child: BlocBuilder<CategoriesCubit, CategoriesState>(
          builder: (context, state) {
            if (state is ListLoadedState) {
              if (state.items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/png/empty_box.png',
                        width: 120.w,
                        height: 120.h,
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'No categories found',
                        style: MyTextStyle.font18BlackBold,
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'Add new categories to get started',
                        style: MyTextStyle.font16Grey,
                      ),
                    ],
                  ),
                );
              }
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.9,
                    mainAxisSpacing: 16.h,
                    crossAxisSpacing: 16.w,
                  ),
                  itemCount: state.items.length,
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    return _buildCategoryCard(item, index, state.items);
                  },
                ),
              );
            } else if (state is LoadingState) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF005A32)),
                  strokeWidth: 2.w,
                ),
              );
            } else if (state is ErrorState) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 48.w),
                    SizedBox(height: 16.h),
                    Text(
                      'Error loading categories',
                      style: MyTextStyle.font18BlackBold,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      state.error,
                      textAlign: TextAlign.center,
                      style: MyTextStyle.font16Grey,
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF005A32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 12.h,
                        ),
                      ),
                      onPressed: loadData,
                      child: Text(
                        'Retry',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return Container();
          },
        ),
      ),
    );
  }

  Widget _buildCategoryCard(Category item, int index, List<Category> items) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade200.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        borderRadius: BorderRadius.circular(20.r),
        color: Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(20.r),
          onTap: () {
            if (item.childrenCount > 0) {
              Navigator.of(context).pushNamed(
                MyRoutes.categories,
                arguments: {"category_id": item.id, "title": item.title},
              );
            } else {
              Navigator.of(context).pushNamed(
                MyRoutes.articles,
                arguments: {"category_id": item.id, "title": item.title},
              );
            }
          },
          splashColor: Colors.green.shade100,
          highlightColor: Colors.green.shade50,
          child: Stack(
            children: [
              // Background with subtle gradient
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.green.shade50,
                      Colors.white,
                    ],
                  ),
                ),
              ),

              // Content
              Padding(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48.w,
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFF005A32).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        item.childrenCount > 0 ? Icons.folder : Icons.article,
                        color: const Color(0xFF005A32),
                        size: 28.w,
                      ),
                    ),

                    SizedBox(height: 12.h),
                    Text(
                      item.title ?? 'Untitled',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontFamily: 'Exo',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    // Item count badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF005A32),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        '${item.childrenCount > 0 ? item.childrenCount : item.articlesCount} items',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (Supabase.instance.client.auth.currentUser != null)
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.black54, size: 24.w),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.blue, size: 20.w),
                            SizedBox(width: 8.w),
                            Text('Edit', style: TextStyle(fontSize: 14.sp)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'move_up',
                        enabled: index > 0,
                        child: Row(
                          children: [
                            Icon(Icons.arrow_upward, color: Colors.green, size: 20.w),
                            SizedBox(width: 8.w),
                            Text('Move Up', style: TextStyle(fontSize: 14.sp)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'move_down',
                        enabled: index < items.length - 1,
                        child: Row(
                          children: [
                            Icon(Icons.arrow_downward, color: Colors.green, size: 20.w),
                            SizedBox(width: 8.w),
                            Text('Move Down', style: TextStyle(fontSize: 14.sp)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) async {
                      if (value == 'edit') {
                        Navigator.of(context).pushNamed(
                          MyRoutes.addCategoryScreen,
                          arguments: {"id": item.id},
                        );
                      } else if (value == 'move_up' && index > 0) {
                        await cubit.swapCategoriesOrder(
                          id1: item.id,
                          id2: items[index - 1].id,
                          index1: index,
                          index2: index - 1,
                        );
                        loadData();
                      } else if (value == 'move_down' && index < items.length - 1) {
                        await cubit.swapCategoriesOrder(
                          id1: item.id,
                          id2: items[index + 1].id,
                          index1: index,
                          index2: index + 1,
                        );
                        loadData();
                      }
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}