import 'package:zad_aldaia/core/models/article_type.dart';

sealed class ArticleItem {
  final String id;
  final String section;
  final String category;
  final String article;
  final String language;
  final String note;
  final int order;
  final ArticleType type;

  ArticleItem({
    required this.id,
    required this.section,
    required this.category,
    required this.article,
    required this.language,
    required this.note,
    required this.type,
    required this.order,
  });

  Map<String, dynamic> toJson();
}

class TextArticle extends ArticleItem {
  final String title;
  final String content;
  final String backgroundColor;

  TextArticle({
    required super.id,
    required super.section,
    required super.category,
    required super.article,
    required super.language,
    required this.title,
    required this.content,
    required super.note,
    required super.order,
    required this.backgroundColor,
  }) : super(type: ArticleType.Text);

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'section': section,
    'category': category,
    'article': article,
    'language': language,
    'note': note,
    'order': order,
    'type': 'Text',
    'title': title,
    'content': content,
    'backgroundColor': backgroundColor,
  };
}

class ImageArticle extends ArticleItem {
  final String url;

  ImageArticle({
    required super.id,
    required super.section,
    required super.category,
    required super.article,
    required super.language,
    required this.url,
    required super.note,
    required super.order,
  }) : super(type: ArticleType.Image);

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'section': section,
    'category': category,
    'article': article,
    'language': language,
    'note': note,
    'order': order,
    'type': 'Image',
    'url': url,
  };
}

class VideoArticle extends ArticleItem {
  final String videoId;

  VideoArticle({
    required super.id,
    required super.section,
    required super.category,
    required super.article,
    required super.language,
    required this.videoId,
    required super.note,
    required super.order,
  }) : super(type: ArticleType.Video);

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'section': section,
    'category': category,
    'article': article,
    'language': language,
    'note': note,
    'order': order,
    'type': 'Video',
    'videoId': videoId,
  };
}
