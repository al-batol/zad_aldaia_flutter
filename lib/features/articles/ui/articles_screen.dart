import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zad_aldaia/core/di/dependency_injection.dart';
import 'package:zad_aldaia/core/routing/routes.dart';
import 'package:zad_aldaia/features/articles/logic/articles_cubit.dart';
import 'package:zad_aldaia/features/articles/ui/widgets/article_item.dart';

class ArticlesScreen extends StatefulWidget {
  final String categoryId;
  final String title;
  final String? section;
  final String? language;

  const ArticlesScreen({
    super.key, 
    required this.categoryId, 
    required this.title, 
    this.section, 
    this.language
  });

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  late ArticlesCubit cubit = getIt<ArticlesCubit>();
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    cubit.loadArticles({'category_id': widget.categoryId});
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset > 300 && !_showScrollToTop) {
      setState(() => _showScrollToTop = true);
    } else if (_scrollController.offset <= 300 && _showScrollToTop) {
      setState(() => _showScrollToTop = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FAE6),
      floatingActionButton: _showScrollToTop
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF005A32),
              child: Icon(Icons.arrow_upward, color: Colors.white, size: 24.w),
              onPressed: () => _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              ),
            )
          : null,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'Exo',
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF005A32), Color(0xFF008A45)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          if (Supabase.instance.client.auth.currentUser != null)
            IconButton(
              icon: Icon(Icons.add, color: Colors.white, size: 24.w),
              onPressed: () => Navigator.of(context).pushNamed(
                MyRoutes.addArticleScreen,
                arguments: {
                  "section": widget.section,
                  "language": widget.language,
                },
              ),
            ),
        ],
      ),
      body: BlocProvider(
        create: (context) => cubit,
        child: BlocBuilder<ArticlesCubit, ArticlesState>(
          builder: (context, state) {
            if (state is LoadingState) {
              return Center(
                child: CircularProgressIndicator(
                  color: const Color(0xFF005A32),
                  strokeWidth: 2.w,
                ),
              );
            }

            if (state is ErrorState) {
              return Center(
                child: Text(
                  state.error,
                  style: TextStyle(color: Colors.red, fontSize: 16.sp),
                ),
              );
            }

            if (state is ListLoadedState) {
              if (state.items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.article_outlined,
                        size: 64.w,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No articles found',
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (Supabase.instance.client.auth.currentUser != null)
                        TextButton(
                          onPressed: () => Navigator.of(context).pushNamed(
                            MyRoutes.addArticleScreen,
                            arguments: {
                              "section": widget.section,
                              "language": widget.language,
                            },
                          ),
                          child: Text(
                            'Create First Article',
                            style: TextStyle(
                              color: const Color(0xFF005A32),
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: const Color(0xFF005A32),
                onRefresh: () async {
                  await cubit.loadArticles({'category_id': widget.categoryId});
                },
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(16.r),
                  itemCount: state.items.length,
                  itemBuilder: (context, index) => Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: ArticleItem(
                      article: state.items[index],
                      onPressed: (article) => Navigator.of(context).pushNamed(
                        MyRoutes.items,
                        arguments: {
                          "id": article.id,
                          "title": article.title,
                        },
                      ),
                    ),
                  ),
                ),
              );
            }

            return Container();
          },
        ),
      ),
    );
  }
}