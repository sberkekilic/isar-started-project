import 'package:flutter/material.dart';
import '../models/article.dart';

class DetailPage extends StatefulWidget {
  final NewsArticle article;
  final int articleIndex;

  const DetailPage(
      {Key? key, required this.article, required this.articleIndex})
      : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  int _articleIndex = 0;
  late NewsArticle _article;

  @override
  void initState() {
    super.initState();
    _articleIndex = widget.articleIndex;
    _article = widget.article;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_articleIndex.toString()),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(_article.image),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _article.title,
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    _article.publishedDate,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    _article.content,
                    style: TextStyle(
                      fontSize: 18.0,
                      height: 1.5,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () {
                          print("GERİ BUTONUNA BASILDI");
                          _articleIndex == 1
                              ? () => Navigator.pop(context, _articleIndex - 1)
                              : () => Navigator.pop(context, _articleIndex - 1);
                        },
                        icon: Icon(Icons.arrow_back_ios),
                        color: _articleIndex == 1 ? Colors.grey : Colors.blue,
                      ),
                      IconButton(
                        onPressed: () {
                          print("İLERİ BUTONUNA BASILDI");
                          _articleIndex == 1
                              ? () => Navigator.pop(context, _articleIndex + 1)
                              : () => Navigator.pop(context, _articleIndex + 1);
                        },
                        icon: Icon(Icons.arrow_forward_ios),
                        color: _articleIndex == 1 ? Colors.grey : Colors.blue,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
