import 'package:zad_aldaia/core/database/my_database.dart' as AI;
import 'package:zad_aldaia/features/article/data/models/article_item.dart';
import 'package:zad_aldaia/core/models/article_type.dart';

extension ArticleTypeExtension on AI.ArticleItem {
  ArticleItem toArticleType() {
    switch (type) {
      case ArticleType.Text:
        return TextArticle(
          id: id,
          section: section,
          category: category,
          article: article,
          title: title!,
          content: content!,
          note: note!,
          language: language,
          order: order,
        );
      case ArticleType.Image:
        return ImageArticle(
          id: id,
          section: section,
          category: category,
          article: article,
          note: note!,
          url: url!,
          language: language,
          order: order,
        );
      case ArticleType.Video:
        return VideoArticle(
          id: id,
          section: section,
          category: category,
          article: article,
          note: note!,
          language: language,
          videoId: videoId!,
          order: order,
        );
    }
  }
}
