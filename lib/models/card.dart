import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../pages/card_detailed.dart';
import 'article.dart';

class NewsCard extends StatelessWidget {
  final NewsArticle article;
  final int articleIndex;

  const NewsCard({Key? key, required this.article, required this.articleIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(article: article, articleIndex: articleIndex),
          ),
        );
      },
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(article.image),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    article.publishedDate,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    article.excerpt,
                    style: TextStyle(
                      fontSize: 16.0,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class NewsData {
  Future<String> _loadArticleAsset() async {
    final String? jsonString =
    await rootBundle.loadString('assets/news/news.json');
    return jsonString ?? 'boş';
  }

  Future<List<NewsArticle>> getArticles() async {
    final String jsonData = await _loadArticleAsset();
    final dynamic jsonResult = json.decode(jsonData);

    if (jsonResult is List) {
      return jsonResult
          .map((article) => NewsArticle.fromJson(article))
          .toList();
    } else if (jsonResult is Map) {
      final List<dynamic> articlesList = jsonResult['articles'];
      return articlesList
          .map((article) => NewsArticle.fromJson(article))
          .toList();
    } else {
      throw Exception('Failed to load articles');
    }
  }

  Future<List<NewsArticle>> get articles async => getArticles();
}

