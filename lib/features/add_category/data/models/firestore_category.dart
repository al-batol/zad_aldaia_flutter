class FireStoreCategory {
  final String title;
  final String section;
  final String lang;

  FireStoreCategory({required this.title,required this.section,required this.lang});

  factory FireStoreCategory.fromJson(Map<String, dynamic> json) {
    return FireStoreCategory(
      title: json['title'] as String,
      section: json['section'] as String,
      lang: json['lang'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'section': section,
      'lang': lang,
    };
  }

  @override
  String toString() {
    print("$title $section $lang");
    return super.toString();
  }

}