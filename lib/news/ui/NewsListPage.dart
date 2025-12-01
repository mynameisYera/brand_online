import 'package:flutter/material.dart' hide Notification;
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
  List<Notification> notifications = [];

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
    _startSplashAndFetch();
  }
  Future<void> _startSplashAndFetch() async {
    final delay = Future.delayed(const Duration(seconds: 0));

    final newsFuture = NewsService().getNews();
    final notifFuture = NewsService().getNotifications();

    final newsResult = await Future.wait([newsFuture, delay]);
    final notifResult = await Future.wait([notifFuture, delay]);

    setState(() {
      newsList = newsResult[0] as List<News>;
      notifications = notifResult[0] as List<Notification>;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Scaffold(
            backgroundColor: Colors.white,
            body: SizedBox.expand(
              child: Center(
                child: LoadingAnimationWidget.progressiveDots(
                  color: GeneralUtil.mainColor,
                  size: MediaQuery.of(context).size.width * 0.2,
                ),
              ),
            ),
          )
        : DefaultTabController(
            length: 2,
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 0,
                centerTitle: true,
                title: const Text(
                  'Деректер',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                bottom: TabBar(
                  labelColor: Colors.black,
                  indicatorColor: Colors.black,
                  tabs: [
                    Tab(text: "Жаңалықтар",),
                    Tab(text: "Хабарламалар",),
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  ListView.builder(
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
                          margin:
                              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                  notifications.isEmpty
                      ? _buildEmptyNotifications()
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: notifications.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final notification = notifications[index];
                            return _NotificationTile(
                              title: notification.title,
                              message: notification.body,
                              time: notification.createdAt.split("T").first,
                              accentColor: colors[index % colors.length],
                            );
                          },
                        ),
                ],
              ),
            ),
          );
  }

  Widget _buildEmptyNotifications() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_none,
              size: MediaQuery.of(context).size.width * 0.2,
              color: Colors.black12),
          const SizedBox(height: 16),
          const Text(
            'Әзірше хабарламалар жоқ',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Жаңалықтар мен маңызды оқиғаларды осы жерден көресіз.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black45),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final String title;
  final String message;
  final String time;
  final Color accentColor;

  const _NotificationTile({
    required this.title,
    required this.message,
    required this.time,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 90,
              color: accentColor,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          time,
                          style: const TextStyle(
                            color: Colors.black45,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      message,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 14),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_active,
                size: 18,
                color: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}