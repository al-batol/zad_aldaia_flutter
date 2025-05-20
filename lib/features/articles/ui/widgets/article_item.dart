import 'package:flutter/material.dart';
import 'package:zad_aldaia/features/articles/data/models/article.dart';

class ArticleItem extends StatelessWidget {
  final Article article;
  final Function(Article) onPressed;

  const ArticleItem({super.key, required this.article, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ListTile(onTap: () => onPressed(article), title: Text(article.title ?? '---'));
  }
}
