import 'package:zad_aldaia/core/database/my_database.dart' as AI;
import 'package:zad_aldaia/features/article/data/models/article_item.dart';
import 'package:zad_aldaia/core/models/article_type.dart';

extension ArticleTypeExtension on AI.ArticleItem {
  ArticleItem toArticleType() {
    switch (type) {
      case ArticleType.Text:
        return TextArticle(id: id, articleId: articleId, title: title!, content: content!, note: note!, order: order);
      case ArticleType.Image:
        return ImageArticle(id: id, articleId: articleId, note: note!, url: url!, order: order);
      case ArticleType.Video:
        return VideoArticle(id: id, articleId: articleId, note: note!, videoId: videoId!, order: order);
    }
  }
}
