import 'package:share_plus/share_plus.dart';
import 'package:zad_aldaia/features/article/data/models/article_item.dart';

class Share {
  static Future<void> multi(List<ArticleItem> items) async {
    String content = items
        .map((item) {
          if (item is TextArticle) {
            return "${item.title} \n ${item.content}";
          } else if (item is ImageArticle) {
            return "Image: ${item.url}";
          } else if (item is VideoArticle) {
            return "Video: ${item.videoId}";
          }
          return item.id;
        })
        .reduce((value, element) => "$value \n------------\n $element");
    SharePlus.instance.share(ShareParams(text: content));
  }

  static article(ArticleItem item) {
    if (item is TextArticle) {
      SharePlus.instance.share(
        ShareParams(title: item.title, text: item.content),
      );
    } else if (item is ImageArticle) {
      SharePlus.instance.share(
        ShareParams(title: item.article, text: item.url),
      );
    } else if (item is VideoArticle) {
      SharePlus.instance.share(
        ShareParams(title: item.article, text: item.videoId),
      );
    }
  }
}
