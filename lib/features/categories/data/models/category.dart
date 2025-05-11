class Category {
  final String id;
  final String title;
  final String section;
  final String language;
  final DateTime createdAt;
  final int order;

  final List<Article>? articles;

  Category({
    required this.id,
    required this.title,
    required this.section,
    required this.language,
    required this.createdAt,
    required this.order,
    this.articles,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      section: json['section'] ?? '',
      language: json['lang'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      order: json['order'] ?? 0,
      articles:
          (json['articles'] as List<dynamic>?)
              ?.map((e) => Article.fromJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'section': section,
      'lang': language,
      'created_at': createdAt.toIso8601String(),
      'order': order,
      'articles': articles?.map((e) => e.toJson()).toList(),
    };
  }
}

class Article {
  final String id;
  final String title;
  final String section;
  final String category;
  final String language;
  final DateTime createdAt;

  Article({
    required this.id,
    required this.title,
    required this.section,
    required this.category,
    required this.language,
    required this.createdAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      section: json['section'] ?? '',
      category: json['category'] ?? '',
      language: json['lang'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'section': section,
      'category': category,
      'lang': language,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
