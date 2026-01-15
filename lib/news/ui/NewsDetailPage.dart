import 'dart:async';
import 'package:brand_online/core/app_colors.dart';
import 'package:brand_online/core/text_styles.dart';
import 'package:brand_online/core/widgets/app_button_widget.dart';
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
  final Color color;

  const NewsDetailPage({super.key, required this.newsId, required this.color});

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
      appBar: AppBar(
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: Text(
          "Жаңалықтар",
          style: TextStyles.bold(AppColors.black, fontSize: 28),
        ),
      ),
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
                Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: widget.color),
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
                                color: widget.color,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Жаңалықтар",
                              style: TextStyles.regular(widget.color, fontSize: 13),
                            ),
                            Spacer(),
                            Text(
                              '${news?.publishedAt.day} ${DateFormat('MMMM', 'kk_KZ').format(news?.publishedAt ?? DateTime.now())}',
                              style: TextStyles.semibold(widget.color, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        Text(
                              news?.title ?? '',
                              style: TextStyles.bold(widget.color, fontSize: 20),
                            ),
                        const SizedBox(height: 6),
                        Divider(
                          color: AppColors.grey,
                          height: 0.7,
                        ),
                        const SizedBox(height: 20),

                        /// HTML Content
                        Center(
                          child: Html(
                            data: news?.content,
                            shrinkWrap: true,
                            style: {
                              "*": Style(
                                fontSize: FontSize(13), fontFamily: 'Manrope',
                                fontWeight: FontWeight.w500,
                                color: AppColors.grey,
                              ),
                            },
                            extensions: [_mathExtension()],
                          ),
                        ),

                        const SizedBox(height: 30),

                        AppButton(
                          onPressed: () => Navigator.pop(context),
                          text: 'КЕРЕМЕТ!',
                        ),
                      ],
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