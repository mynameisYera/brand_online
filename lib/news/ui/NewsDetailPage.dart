import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../service/news_service.dart';
import '../entity/NewsDetailed.dart';
import '../../general/GeneralUtil.dart';
class NewsDetailPage extends StatefulWidget {
  final int newsId;

  const NewsDetailPage({super.key, required this.newsId});

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  bool showSplash = true;
  NewsDetailed? news;

  @override
  void initState() {
    super.initState();
    _startSplashAndLoad();
  }

  Future<void> _startSplashAndLoad() async {
    final delay = Future.delayed(const Duration(seconds: 0));
    final fetch = NewsService().getNewsDetail(widget.newsId);

    final results = await Future.wait([fetch, delay]);

    setState(() {
      news = results[0] as NewsDetailed?;
      showSplash = false;

      if (news != null) {
        news!.content = news!.content.replaceAll(
          'src="/media/',
          'src="${GeneralUtil.BASE_URL}/media/',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showSplash) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SizedBox.expand(
          child: Center(
            child: LoadingAnimationWidget.progressiveDots(
              color: GeneralUtil.mainColor,
              size: MediaQuery.of(context).size.width * 0.2,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: news == null
            ? const Center(child: Text("Жаңалық табылмады"))
            : Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Top bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      DateFormat('dd.MM.yyyy').format(
                        DateTime.parse(news!.publishedAt 
                        // ?? DateTime.now().toIso8601String()
                        ),
                      ),
                      style: const TextStyle(color: Colors.grey),
                    )
                  ],
                ),
                const SizedBox(height: 20),

                /// HTML Content
                Center(
                  child: Html(
                    data: news?.content,
                    shrinkWrap: true,
                    style: {
                      "*": Style(
                        fontSize: FontSize(18),
                      ),
                    },
                    extensions: [_mathExtension()],
                  ),
                ),

                const SizedBox(height: 30),

                /// Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'КЕРЕМЕТ!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TagExtension _mathExtension() {
    return TagExtension(
      tagsToExtend: {"span"},
      builder: (extensionContext) {
        final formula = extensionContext.innerHtml
            .replaceAll(r"\(", "")
            .replaceAll(r"\)", "");

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          margin: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Math.tex(
            formula,
            mathStyle: MathStyle.text,
            textStyle: const TextStyle(fontSize: 16, color: Colors.black),
          ),
        );
      },
    );
  }
}