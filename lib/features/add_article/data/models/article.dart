class Article {
  final String? id;
  final String title;
  final String section;
  final String category;
  final String lang;
  final String categoryId;
  Article({
    this.id,
    required this.title,
    required this.section,
    required this.category,
    required this.lang,
    required this.categoryId,
  });

  factory Article.fromJson(Map<String, dynamic> map) {
    return Article(
      id: map['id'],
      title: map['title'],
      section: map['section'],
      category: map['category'],
      lang: map['lang'],
      categoryId: map['category_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'section': section,
      'category': category,
      'lang': lang,
      'category_id': categoryId,
    };
  }
}
