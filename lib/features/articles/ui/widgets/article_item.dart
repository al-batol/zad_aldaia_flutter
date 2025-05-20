import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zad_aldaia/core/routing/routes.dart';
import 'package:zad_aldaia/features/articles/data/models/article.dart';

class ArticleItem extends StatelessWidget {
  final Article article;
  final Function(Article) onPressed;

  const ArticleItem({super.key, required this.article, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => onPressed(article),
      title: Card(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Row(
            children: [
              Expanded(child: Text(article.title ?? '---', textAlign: TextAlign.center)),
              if (Supabase.instance.client.auth.currentUser != null)
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(MyRoutes.addArticleScreen, arguments: {"id": article.id});
                  },
                  icon: Icon(Icons.edit, color: Colors.amber),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
