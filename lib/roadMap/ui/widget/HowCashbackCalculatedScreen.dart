import 'package:brand_online/core/widgets/app_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class HowCashbackCalculatedScreen extends StatefulWidget {
  final String title;
  final String url;

  const HowCashbackCalculatedScreen({
    super.key,
    this.title = 'Қалай есептеледі?',
    this.url = 'https://youtu.be/eujigBLxbLY?feature=shared',
  });

  @override
  State<HowCashbackCalculatedScreen> createState() =>
      _HowCashbackCalculatedScreenState();
}

class _HowCashbackCalculatedScreenState
    extends State<HowCashbackCalculatedScreen> {
  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();
    final id = _extractVideoId(widget.url);
    if (id == null || id.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Видео не найдено')),
          );
          Navigator.of(context).maybePop();
        }
      });
      return;
    }

    _controller = YoutubePlayerController.fromVideoId(
      videoId: id,
      autoPlay: true,
      params: const YoutubePlayerParams(
        mute: false,
        loop: false,
        showControls: true,
        showFullscreenButton: true,
        enableCaption: false,
        showVideoAnnotations: false,
        strictRelatedVideos: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  String? _extractVideoId(String url) {
    final regExp = RegExp(r'(?:v=|\/|embed\/|youtu\.be\/)([0-9A-Za-z_-]{11})');
    final match = regExp.firstMatch(url);
    return match?.group(1);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const SizedBox.shrink(),
      );
    }

    return YoutubePlayerScaffold(
      controller: controller,
      aspectRatio: 16 / 9,
      builder: (context, player) => Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: SafeArea(
          child: Column(
            children: [
              player,
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: AppButton(
                  text: "ТҮСІНІКТІ",
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
