class NewsArticle {
  final String title;
  final String image;
  final String publishedDate;
  final String content;
  final String excerpt;
  final int index;

  NewsArticle({
    required this.title,
    required this.image,
    required this.publishedDate,
    required this.content,
    required this.excerpt,
    required this.index
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'],
      image: json['image'],
      publishedDate: json['publishedDate'],
      content: json['content'],
      excerpt: json['content'].toString().substring(0, 100),
      index: json['index']
    );
  }
}
