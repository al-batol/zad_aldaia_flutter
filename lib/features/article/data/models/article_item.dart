import 'package:zad_aldaia/core/models/article_type.dart';

sealed class ArticleItem {
  final String id;
  final String articleId;
  final String note;
  final int order;
  final ArticleType type;

  ArticleItem({required this.id, required this.articleId, required this.note, required this.type, required this.order});

  factory ArticleItem.fromJson(Map<String, dynamic> json) {
    final type = json['type'];

    switch (type) {
      case 'Text':
        return TextArticle(id: json['id'], articleId: json['article_id'], title: json['title'], content: json['content'], note: json['note'] ?? '', order: json['order'] ?? 0);
      case 'Image':
        return ImageArticle(id: json['id'], articleId: json['article_id'], url: json['url'], note: json['note'] ?? '', order: json['order'] ?? 0);
      case 'Video':
        return VideoArticle(id: json['id'], articleId: json['article_id'], videoId: json['videoId'], note: json['note'] ?? '', order: json['order'] ?? 0);
      default:
        throw Exception('نوع مقال غير معروف: $type');
    }
  }

  Map<String, dynamic> toJson();
}

class TextArticle extends ArticleItem {
  final String title;
  final String content;

  TextArticle({required super.id, required super.articleId, required this.title, required this.content, required super.note, required super.order}) : super(type: ArticleType.Text);

  @override
  Map<String, dynamic> toJson() => {'id': id, 'article_id': articleId, 'note': note, 'order': order, 'type': 'Text', 'title': title, 'content': content};
}

class ImageArticle extends ArticleItem {
  final String url;

  ImageArticle({required super.id, required super.articleId, required this.url, required super.note, required super.order}) : super(type: ArticleType.Image);

  @override
  Map<String, dynamic> toJson() => {'id': id, 'article_id': articleId, 'note': note, 'order': order, 'type': 'Image', 'url': url};
}

class VideoArticle extends ArticleItem {
  final String videoId;

  VideoArticle({required super.id, required super.articleId, required this.videoId, required super.note, required super.order}) : super(type: ArticleType.Video);

  @override
  Map<String, dynamic> toJson() => {'id': id, 'article_id': articleId, 'note': note, 'order': order, 'type': 'Video', 'videoId': videoId};
}
