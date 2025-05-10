import '../../../add_article/data/models/article.dart';

class Category {
  final String id;
  final String title;
  final String section;
  final String lang;
  final DateTime createdAt;
  final int order;

  // خلي articles اختيارية عشان تضيفها لاحقًا لو محتاج
  final List<Article> articles;

  Category({
    required this.id,
    required this.title,
    required this.section,
    required this.lang,
    required this.createdAt,
    required this.order,
    this.articles = const [],
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      title: json['title'] as String,
      section: json['section'] as String,
      lang: json['lang'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      order: json['order'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'section': section,
      'lang': lang,
      'created_at': createdAt.toIso8601String(),
      'order': order,
      'articles': articles.map((e) => e.toJson()).toList(),
    };
  }
}
