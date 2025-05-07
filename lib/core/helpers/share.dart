import 'package:share_plus/share_plus.dart';
import 'package:zad_aldaia/features/article/data/models/article_item.dart';

class Share {
  static article(ArticleItem item) {
    if (item is TextArticle) {
      SharePlus.instance.share(ShareParams(title: item.title, text: item.content));
    } else if (item is ImageArticle) {
      SharePlus.instance.share(ShareParams(title: item.article, text: item.url));
    } else if (item is VideoArticle) {
      SharePlus.instance.share(ShareParams(title: item.article, text: item.videoId));
    }
  }
}
