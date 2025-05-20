import 'package:share_plus/share_plus.dart';
import 'package:zad_aldaia/features/article/data/models/article_item.dart';
import 'package:zad_aldaia/features/items/data/models/item.dart';

class Share {
  static Future<void> multi(List<Item> items) async {
    String content = items
        .map((item) {
          if (item is TextArticle) {
            return "${item.title} \n ${item.content}";
          } else if (item is ImageArticle) {
            return "Image: ${item.imageUrl}";
          } else if (item is VideoArticle) {
            return "Video: ${item.youtubeUrl}";
          }
          return item.id;
        })
        .reduce((value, element) => "$value \n------------\n $element");
    SharePlus.instance.share(ShareParams(text: content));
  }

  static article(ArticleItem item) {
    if (item is TextArticle) {
      SharePlus.instance.share(ShareParams(title: item.title, text: item.content));
    } else if (item is ImageArticle) {
      SharePlus.instance.share(ShareParams(title: item.note, text: item.url));
    } else if (item is VideoArticle) {
      SharePlus.instance.share(ShareParams(title: item.note, text: item.videoId));
    }
  }

  static item(Item item) {
    if (item is TextArticle) {
      SharePlus.instance.share(ShareParams(title: item.title, text: item.content));
    } else if (item is ImageArticle) {
      SharePlus.instance.share(ShareParams(title: item.note, text: item.imageUrl));
    } else if (item is VideoArticle) {
      SharePlus.instance.share(ShareParams(title: item.note, text: item.youtubeUrl));
    }
  }
}
