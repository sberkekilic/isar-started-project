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
      title: json['title'] as String,
      image: json['image'] as String,
      publishedDate: json['publishedDate'] as String,
      content: json['content'] as String,
      excerpt: json['content'].toString().substring(0, 100) as String,
      index: json['index'] as int
    );
  }
}
