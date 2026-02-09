import 'package:brand_online/core/app_colors.dart';
import 'package:brand_online/core/service/display_chacker.dart';
import 'package:brand_online/core/text_styles.dart';
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
    Color(0xff2196F3),
    Color(0xffFF6700),
    Color(0xffFF40D6),
    Color(0xffFFC430),
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
        shadowColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Жаңалықтар",
          style: TextStyles.bold(AppColors.black, fontSize: 28),
        ),
      ),
      body: isLoading
          ? SizedBox.expand(
              child: Center(
                child: LoadingAnimationWidget.progressiveDots(
                  color: GeneralUtil.mainColor,
                  size: 100,
                ),
              ),
            )
          : Center(child: Container(
            width: DisplayChacker.isDisplay(context) ? double.infinity : 770,
            child: ListView.builder(
              itemCount: newsList.length,
              itemBuilder: (context, index) {
                final news = newsList[index];
                final color = colors[index % colors.length];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NewsDetailPage(newsId: news.id, color: color),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.grey),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 6,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Жаңалықтар",
                              style: TextStyles.regular(color, fontSize: 13),
                            ),
                            Spacer(),
                            Text(
                              '${news.publishedAt.day} ${DateFormat('MMMM', 'kk_KZ').format(news.publishedAt)}',
                              style: TextStyles.semibold(AppColors.grey, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        Text(
                              news.title,
                              style: TextStyles.bold(color, fontSize: 20),
                            ),
                        const SizedBox(height: 6),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
    ));
  }
}