import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

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
    if (id == null) {
      // Можешь заменить на свой UI
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Видео не найдено')),
        );
        Navigator.of(context).maybePop();
      });
      return;
    }

    _controller = YoutubePlayerController(
      initialVideoId: id,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        loop: false,
        disableDragSeek: false,
        enableCaption: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  String? _extractVideoId(String url) {
    final regExp =
    RegExp(r'(?:v=|\/|embed\/|youtu\.be\/)([0-9A-Za-z_-]{11})');
    final match = regExp.firstMatch(url);
    return match?.group(1);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: controller == null
          ? const SizedBox.shrink()
          : SafeArea(
        child: Column(
          children: [
            // сам плеер
            AspectRatio(
              aspectRatio: 16 / 9,
              child: YoutubePlayer(
                controller: controller,
                showVideoProgressIndicator: true,
                  bottomActions: [
                    const SizedBox(width: 8),
                    CurrentPosition(),
                    const SizedBox(width: 10),
                    ProgressBar(
                      isExpanded: true,
                      colors: const ProgressBarColors(
                        playedColor: Colors.blueAccent,
                        handleColor: Colors.blue,
                        bufferedColor: Color(0xFF90CAF9),
                        backgroundColor: Color(0xFFE3F2FD),
                      ),
                    ),
                    const SizedBox(width: 10),
                    RemainingDuration(),
                    const SizedBox(width: 10),
                    FullScreenButton(),
                  ],
              ),
            ),
            const Spacer(),
            // Кнопка "понятно" (по желанию)
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: const Text(
                    'ТҮСІНІКТІ!',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
