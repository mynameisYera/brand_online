import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../general/GeneralUtil.dart';
import '../entity/News.dart';
import '../service/news_service.dart';
import 'NewsDetailPage.dart';

class NewsListPage extends StatefulWidget {
  const NewsListPage({super.key});

  @override
  State<NewsListPage> createState() => _NewsListPageState();
}

class _NewsListPageState extends State<NewsListPage> {
  List<News> newsList = [];
  bool isLoading = true;

  final List<Color> colors = [
    Color.fromRGBO(75, 167, 255, 1.0),
    Color.fromRGBO(141, 223, 84, 1.0),
    Color.fromRGBO(211, 157, 255, 1.0),
    Color.fromRGBO(255, 217, 66, 1.0),
    Color.fromRGBO(255, 130, 85, 1.0),
  ];

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    final newsResult = await NewsService().getNews();
    setState(() {
      newsList = newsResult;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Жаңалықтар',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: isLoading
          ? SizedBox.expand(
              child: Center(
                child: LoadingAnimationWidget.progressiveDots(
                  color: GeneralUtil.mainColor,
                  size: MediaQuery.of(context).size.width * 0.2,
                ),
              ),
            )
          : ListView.builder(
              itemCount: newsList.length,
              itemBuilder: (context, index) {
                final news = newsList[index];
                final color = colors[index % colors.length];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NewsDetailPage(newsId: news.id),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Заголовок
                        Text(
                          news.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),

                        /// Дата и стрелка
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('dd.MM.yyyy').format(news.publishedAt),
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const Icon(Icons.arrow_forward_ios,
                                size: 16, color: Colors.white),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}