import '../../../add_article/data/models/article.dart';

class Category {
  final String title;
  final List<Article> articles;

  Category({required this.title, required this.articles});
}
