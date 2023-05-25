import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../blocs/settings/settings_cubit.dart';
import '../localizations/localizations.dart';
import 'article.dart';

class NewsListPage extends StatefulWidget {
  @override
  State<NewsListPage> createState() => _NewsListPageState();
}

class _NewsListPageState extends State<NewsListPage> {
  late Future<List<NewsArticle>> _articlesFuture;
  late SettingsCubit settings;
  late int _maxId;

  askLogout() {
    showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(AppLocalizations.of(context).getTranslate("logout")),
        content: Text(AppLocalizations.of(context).getTranslate("logout_confirm")),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text(AppLocalizations.of(context).getTranslate("yes")),
            onPressed: () {
              settings.userLogout();
              Navigator.of(context).pop();
              GoRouter.of(context).replace('/welcome');
            },),
          CupertinoDialogAction(
            child: Text(AppLocalizations.of(context).getTranslate("no")),
            onPressed: () {
              Navigator.of(context).pop();
            },),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _articlesFuture = fetchNews(context);
    _maxId = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 50,
        title: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                // Geri butonuna basıldığında yapılacak işlemler
                GoRouter.of(context).push('/welcome'); // Anasayfaya yönlendirme
              },
            ),
            Text('Örnek'),
          ],
        ),
        automaticallyImplyLeading: false,
        actions: [
          Builder(
            builder: (context) {
              final userLoggedIn = context.select((SettingsCubit cubit) => cubit.state.userLoggedIn);
              if (userLoggedIn) {
                return Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.settings),
                      onPressed: () {
                        // Çıkış yap butonuna basıldığında yapılacak işlemler
                        GoRouter.of(context).push('/settings'); // Anasayfaya yönlendirme
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.person_4_rounded),
                      onPressed: () {
                        // Çıkış yap butonuna basıldığında yapılacak işlemler
                        GoRouter.of(context).push('/profile'); // Anasayfaya yönlendirme
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.exit_to_app),
                      onPressed: () {
                        askLogout();
                      },
                    )
                  ],
                );
              } else {
                return IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () {
                    // Çıkış yap butonuna basıldığında yapılacak işlemler
                    GoRouter.of(context).push('/settings'); // Anasayfaya yönlendirme
                  },
                );
              }
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
                              item: items[index], news: items, maxId: _maxId),
                        ),
                      );
                    },
                    child: Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.network(items[index].image),
                          Padding(padding: EdgeInsets.all(8)),
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
    final jsonString = await DefaultAssetBundle.of(context)
        .loadString('assets/news/news.json');
    final jsonItems = jsonDecode(jsonString)['articles'] as List<dynamic>;

    for (var jsonItem in jsonItems) {
      final item = NewsArticle.fromJson(jsonItem);
      if (item.index > _maxId) {
        _maxId = item.index;
      }
    }

    return jsonItems.map((jsonItem) => NewsArticle.fromJson(jsonItem)).toList();
  }
}

class NewsDetailPage extends StatefulWidget {
  final NewsArticle item;
  final List<NewsArticle> news;
  final int maxId;

  NewsDetailPage({required this.news, required this.item, required this.maxId});

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  late List<NewsArticle> _loadedNews;
  bool _isLoading = false;
  bool _isListFinished = false;
  bool _allowScroll = true;
  ScrollController _scrollController = ScrollController();
  int? deger;

  @override
  void initState() {
    super.initState();
    _loadedNews = [widget.item];
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (!_isLoading &&
        _scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
      if (!_isListFinished && _allowScroll) {
        _loadNextNews();
      }
    } else if (_scrollController.position.pixels ==
        _scrollController.position.minScrollExtent) {
      // Kullanıcı listenin başına kaydırırsa tekrar yüklemeyi etkinleştir
      _allowScroll = true;
    }

    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      _allowScroll = true;
    }
  }

  void _loadNextNews() async {
    if (_loadedNews.length < widget.news.length) {
      setState(() {
        _isLoading = true;
      });

      // Simulating a delay of 3 seconds
      await Future.delayed(Duration(seconds: 3));

      final currentIndex = widget.news.indexOf(_loadedNews.last);
      final nextIndex = currentIndex + 1;

      if (nextIndex < widget.news.length) {
        final nextItem = widget.news[nextIndex];
        _loadedNews.add(nextItem);
      }
      setState(() {
        //deger = _loadedItems.last.id;
        print('2 ÖNEMLİ VERİ! ${widget.news[_loadedNews.length]}');
        //_loadedItems.add(nextItem);
        for (var item in _loadedNews) {
          print('_loadedItems 2 | ID: ${item.index}');
        }
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _isListFinished = true;
        _allowScroll = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentID = _loadedNews.last.index;
    return Scaffold(
      appBar: AppBar(
        title: Text("ID: $currentID"),
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: _loadedNews.length + (_isLoading ? 1 : 0) + 1,
        physics: _allowScroll
            ? AlwaysScrollableScrollPhysics()
            : NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          if (index < _loadedNews.length) {
            final item = _loadedNews[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              child: Container(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.network(
                      item.image,
                      fit: BoxFit.cover,
                      height:
                          200, // Belirli bir yükseklik verin veya istediğiniz gibi ayarlayın
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                      title: Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: Text(item.title,
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold)),
                      ),
                      subtitle: Text(
                        "${item.publishedDate}\n\n${item.content}",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            if (currentID == widget.maxId) {
              return ListTile(
                title: Center(
                  child: Text('Liste bitti'),
                ),
              );
            } else {
              return ListTile(
                title: Center(
                  child: _isLoading ? CircularProgressIndicator() : null,
                ),
              );
            }
          }
        },
      ),
    );
  }
}
