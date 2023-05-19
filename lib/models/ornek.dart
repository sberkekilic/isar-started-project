import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'article.dart';

class NewsListPage extends StatefulWidget {
  @override
  State<NewsListPage> createState() => _NewsListPageState();
}

class _NewsListPageState extends State<NewsListPage> {
  late Future<List<NewsArticle>> _articlesFuture;

  @override
  void initState() {
    super.initState();
    _articlesFuture = fetchNews(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('News App'),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              // Çıkış yap butonuna basıldığında yapılacak işlemler
              GoRouter.of(context).go('/welcome'); // Anasayfaya yönlendirme
            },
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder<List<NewsArticle>>(
          future: _articlesFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final items = snapshot.data!;
              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NewsDetailPage(
                            news: items,
                            selectedIndex: index,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network(items[index].image),
                          Padding(padding: EdgeInsets.all(16)),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                items[index].title,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                items[index].publishedDate,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                '${items[index].excerpt}[...]',
                                style: TextStyle(fontSize: 16, height: 1.5),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              print("CIRCULAR 1 DEBUG");
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }

  Future<List<NewsArticle>> fetchNews(BuildContext context) async {
    final jsonString =
    await DefaultAssetBundle.of(context).loadString('assets/news/news.json');
    final jsonItems = jsonDecode(jsonString)['articles'] as List<dynamic>;
    return jsonItems.map((jsonItem) => NewsArticle.fromJson(jsonItem)).toList();
  }
}

class NewsDetailPage extends StatefulWidget {
  final List<NewsArticle> news;
  final int selectedIndex;

  NewsDetailPage({required this.news, required this.selectedIndex});

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  late List<NewsArticle> _news = [];
  List<NewsArticle> _loadedNews = [];
  ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadNews();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (!_isLoading &&
        _scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
      _loadNextNews();
    }
  }

  void _loadNews() async {
    setState(() {
      _isLoading = true;
    });

    final jsonString = await DefaultAssetBundle.of(context)
        .loadString('assets/news/news.json');
    final jsonItems = jsonDecode(jsonString)['articles'] as List<dynamic>;
    _news = jsonItems.map((jsonItem) => NewsArticle.fromJson(jsonItem)).toList();

    _loadedNews.add(widget.news[widget.selectedIndex]);

    setState(() {
      _isLoading = false;
    });

    await Future.delayed(Duration(seconds: 3));
  }

  void _loadNextNews() async {
    if (_currentIndex + 1 < _news.length) {
      setState(() {
        _isLoading = true;
        _currentIndex++;
        _loadedNews.add(_news[_currentIndex]);
      });

      await Future.delayed(Duration(seconds: 3));

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AppBar"),
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: _loadedNews.length + (_isLoading ? 1 : 0),
        itemBuilder: (BuildContext context, int index) {
          if (index < _loadedNews.length) {
            final item = _loadedNews[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              child: ListTile(
                title: Text(item.title, style: TextStyle(fontSize: 30)),
                subtitle: Text(
                  item.content,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            );
          } else if (_isLoading) {
            // Render loading indicator
            return Container(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            // Render empty container when index is out of range
            return Container();
          }
        },
      ),
    );
  }
}











