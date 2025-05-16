class FireStoreCategory {
  final String? id;
  final String title;
  final String section;
  final String lang;

  FireStoreCategory({
    this.id,
    required this.title,
    required this.section,
    required this.lang,
  });

  factory FireStoreCategory.fromJson(Map<String, dynamic> json) {
    return FireStoreCategory(
      id: json['id'] as String?,
      title: json['title'] as String,
      section: json['section'] as String,
      lang: json['lang'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'section': section, 'lang': lang};
  }

  @override
  String toString() {
    print("$title $section $lang");
    return super.toString();
  }
}
