import 'package:brand_online/core/app_colors.dart';
import 'package:brand_online/core/widgets/app_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:brand_online/authorization/entity/RoadMapResponse.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class AnswerVideoPopup extends StatefulWidget {
  final String videoSolutionUrl;
  final Lesson lesson;

  const AnswerVideoPopup({super.key, required this.videoSolutionUrl, required this.lesson});

  @override
  State<AnswerVideoPopup> createState() => _AnswerVideoPopupState();
}

class _AnswerVideoPopupState extends State<AnswerVideoPopup> {
  YoutubePlayerController? _controller;
  bool _markedWatched = false;
  bool _isValid = false;
  final _noScreenshot = NoScreenshot.instance;
  static const List<double> _playbackRates = [1.0, 1.5, 2.0];

  // screenshot
  void disableScreenshot() async {
    bool result = await _noScreenshot.screenshotOff();
    debugPrint('Screenshot Off: $result');
  }

  void enableScreenshot() async {
    bool result = await _noScreenshot.screenshotOn();
    debugPrint('Screenshot On: $result');
  }

  @override
  void initState() {
    super.initState();
    final videoId = _extractVideoId(widget.videoSolutionUrl);
    enableScreenshot();
    if (videoId.isNotEmpty) {
      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          loop: true,
          disableDragSeek: false,
          enableCaption: false,
        ),
      )..addListener(_listener);

      _controller!.cue(videoId, startAt: 0);
      _isValid = true;
    }
  }

  void _listener() {
    final controller = _controller;
    if (controller == null) return;
    if (controller.value.playerState == PlayerState.ended && !_markedWatched) {
      _onVideoEnded();
    }
  }

  void _onVideoEnded() {
    _markedWatched = true;
    Navigator.of(context).pop();
  }

  void _markVideoAsWatched({bool shouldPopOnSuccess = true}) async {
    if (_markedWatched) return;
    _markedWatched = true;
    if (shouldPopOnSuccess && mounted) {
          Navigator.of(context).pop(true);
        }
  }

  String _extractVideoId(String url) {
    final regExp = RegExp(
      r'(?:v=|\/|embed\/|youtu\.be\/)([0-9A-Za-z_-]{11})',
    );
    final match = regExp.firstMatch(url);
    return match != null ? match.group(1)! : '';
  }


  @override
  void dispose() {
    _controller?.removeListener(_listener);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isValid || _controller == null) {
      return const Scaffold(
        body: Center(child: Text("Видео сілтемесі дұрыс емес")),
      );
    }

    final controller = _controller!;

    return YoutubePlayerBuilder(
      player: YoutubePlayer(
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
          _buildPlaybackSpeedButton(controller),
          const SizedBox(width: 10),
          FullScreenButton(),
        ],
      ),
      builder: (context, player) => Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 20),
              Container(
                width: 100,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.grey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  widget.lesson.lessonTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                margin: EdgeInsets.symmetric(horizontal: 16),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: player,
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: AppButton(
                  onPressed: () {
                      enableScreenshot();
                      _markVideoAsWatched();
                    },
                  text: "Түсінікті",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildPlaybackSpeedButton(YoutubePlayerController controller) {
    return ValueListenableBuilder<YoutubePlayerValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        final currentRate = value.playbackRate;
        String formatRate(double rate) {
          final isInt = rate.truncateToDouble() == rate;
          return isInt ? rate.toStringAsFixed(0) : rate.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '');
        }

        return PopupMenuButton<double>(
          tooltip: 'Playback speed',
          onSelected: (rate) {
            if (rate != currentRate) {
              controller.setPlaybackRate(rate);
            }
          },
          itemBuilder: (context) => _playbackRates
              .map(
                (rate) => PopupMenuItem<double>(
                  value: rate,
                  child: Text(
                    'x${formatRate(rate)}',
                    style: TextStyle(
                      fontWeight: rate == currentRate ? FontWeight.w600 : FontWeight.normal,
                      color: rate == currentRate ? Colors.blueAccent : Colors.black87,
                    ),
                  ),
                ),
              )
              .toList(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.speed, color: Colors.white, size: 18),
                const SizedBox(width: 4),
                Text(
                  'x${formatRate(currentRate)}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
