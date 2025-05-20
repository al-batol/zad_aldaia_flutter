import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zad_aldaia/core/di/dependency_injection.dart';
import 'package:zad_aldaia/core/routing/routes.dart';
import 'package:zad_aldaia/features/articles/logic/articles_cubit.dart';
import 'package:zad_aldaia/features/articles/ui/widgets/article_item.dart';
import '../../../core/theming/my_text_style.dart';

class ArticlesScreen extends StatefulWidget {
  final String categoryId;
  final String title;
  final String? section;
  final String? language;

  const ArticlesScreen({super.key, required this.categoryId, required this.title, this.section, this.language});

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  late ArticlesCubit cubit = getIt<ArticlesCubit>();

  @override
  void initState() {
    cubit.loadArticles({'category_id': widget.categoryId});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleTextStyle: MyTextStyle.font22primaryBold,
        title: Text(widget.title),
        actions: [
          if (Supabase.instance.client.auth.currentUser != null)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).pushNamed(MyRoutes.addArticleScreen, arguments: {"section": widget.section, "language": widget.language});
              },
            ),
        ],
      ),
      body: SizedBox.expand(
        child: BlocProvider(
          create: (context) => cubit,
          child: BlocBuilder<ArticlesCubit, ArticlesState>(
            builder: (context, state) {
              if (state is ListLoadedState) {
                if (state.items.isEmpty) {
                  return Center(child: Text('Empty'));
                }
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: state.items.length,
                        itemBuilder:
                            (context, index) => ArticleItem(
                              article: state.items[index],
                              onPressed:
                                  (p0) => Navigator.of(context).pushNamed(MyRoutes.articleScreen, arguments: {"id": state.items[index].id, "title": state.items[index].title}),
                            ),
                      ),
                    ),
                  ],
                );
              } else {
                return Container();
              }
            },
          ),
        ),
      ),
    );
  }
}
