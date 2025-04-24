class Article {
  final String title;
  final String section;
  final String category;
  final String lang;

  Article({
    required this.title,
    required this.section,
    required this.category,
    required this.lang,
  });


  factory Article.fromJson(Map<String, dynamic> map) {
    return Article(
      title: map['title'],
      section: map['section'],
      category: map['category'],
      lang: map['lang'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'section': section,
      'category': category,
      'lang': lang,
    };
  }
}