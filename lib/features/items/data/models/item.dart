enum ItemType { text, image, video }

class Item {
  String id;
  String? articleId;
  int? order;
  ItemType type;
  String? backgroundColor;
  String? note;
  String? title;
  String? content;
  String? youtubeUrl;
  String? createdAt;
  String? imageUrl;
  String? imageIdentifier;

  Item({
    required this.id,
    this.note,
    this.order,
    this.type = ItemType.text,
    this.title,
    this.content,
    this.imageUrl,
    this.youtubeUrl,
    this.createdAt,
    this.backgroundColor,
    this.articleId,
    this.imageIdentifier,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json['id'],
    note: json['note'],
    order: json['order'],
    type: ItemType.values.where((element) => element.name == json['type']).first,
    title: json['title'],
    content: json['content'],
    imageUrl: json['image_url'],
    youtubeUrl: json['youtube_url'],
    createdAt: json['created_at'],
    backgroundColor: json['background_color'],
    articleId: json['article_id'],
    imageIdentifier: json['image_identifier'],
  );

  // Map<String, dynamic> toJson() => {
  //   "id": id,
  //   "note": note,
  //   "order": order,
  //   "type": type.name,
  //   "title": title,
  //   "content": content,
  //   "image_url": imageUrl,
  //   "youtube_url": youtubeUrl,
  //   "created_at": createdAt,
  //   "background_color": backgroundColor,
  //   "article_id": articleId,
  //   "image_identifier": imageIdentifier,
  // };
  Map<String, dynamic> toFormJson() => {
    "article_id": articleId,
    "note": note,
    "order": order ?? 0,
    "type": type.name,
    "title": title,
    "content": content,
    "image_url": imageUrl,
    "youtube_url": youtubeUrl,
    "background_color": backgroundColor,
    "image_identifier": imageIdentifier,
  };
}
