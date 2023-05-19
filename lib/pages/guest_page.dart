import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:isar_starter_project/pages/card_detailed.dart';
import 'dart:convert';

import '../blocs/settings/settings_cubit.dart';
import '../models/article.dart';
import '../models/card.dart';

class NewsPage extends StatelessWidget {
  final NewsData newsData = NewsData();

  NewsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        appBar: AppBar(
          title: Text('News App'),
          actions: [
            Builder(
              builder: (context) {
                final userLoggedIn = context.select((SettingsCubit cubit) => cubit.state.userLoggedIn);
                if (userLoggedIn) {
                  return Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.exit_to_app),
                        onPressed: () {
                          // Çıkış yap butonuna basıldığında yapılacak işlemler
                          context.read<SettingsCubit>().userLogout(); // Kullanıcı çıkışını gerçekleştirir
                          GoRouter.of(context).go('/welcome'); // Anasayfaya yönlendirme
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          // Geri butonuna basıldığında yapılacak işlemler
                          GoRouter.of(context).go('/welcome'); // Anasayfaya yönlendirme
                        },
                      ),
                    ],
                  );
                } else {
                  return IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      // Geri butonuna basıldığında yapılacak işlemler
                      GoRouter.of(context).go('/welcome'); // Anasayfaya yönlendirme
                    },
                  );
                }
              },
            ),
          ],
        ),
          body: FutureBuilder(
          future: newsData.getArticles(),
          builder: (BuildContext context, AsyncSnapshot<List<NewsArticle>> snapshot) {
            if (snapshot.hasData) {
              final List<NewsArticle> articles = snapshot.data!;
              return ListView.builder(
                itemCount: articles.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context, 
                          MaterialPageRoute(
                          builder:(context) => DetailPage
                        (article: articles[index], articleIndex: articles[index].index,
                      ),
                      ),
                      );
                    },
                    child: NewsCard(article: articles[index], articleIndex: articles[index].index,),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('${snapshot.error}'));
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}












