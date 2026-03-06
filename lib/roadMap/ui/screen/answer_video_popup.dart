import 'dart:async';

import 'package:brand_online/core/app_colors.dart';
import 'package:brand_online/core/widgets/app_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:brand_online/authorization/entity/RoadMapResponse.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class AnswerVideoPopup extends StatefulWidget {
  final String videoSolutionUrl;
  final Lesson lesson;

  const AnswerVideoPopup({super.key, required this.videoSolutionUrl, required this.lesson});

  @override
  State<AnswerVideoPopup> createState() => _AnswerVideoPopupState();
}

class _AnswerVideoPopupState extends State<AnswerVideoPopup> {
  YoutubePlayerController? _controller;
  StreamSubscription<YoutubePlayerValue>? _controllerSubscription;
  bool _markedWatched = false;
  bool _isValid = false;
  static const List<double> _playbackRates = [1.0, 1.5, 2.0];

  @override
  void initState() {
    super.initState();
    final videoId = _extractVideoId(widget.videoSolutionUrl);
    // enableScreenshot();
    if (videoId.isNotEmpty) {
      _controller = YoutubePlayerController.fromVideoId(
        videoId: videoId,
        autoPlay: false,
        params: const YoutubePlayerParams(
          mute: false,
          loop: true,
          showControls: true,
          showFullscreenButton: true,
          enableCaption: false,
          showVideoAnnotations: false,
          strictRelatedVideos: true,
        ),
      );
      _controllerSubscription = _controller!.listen(_onPlayerStateChanged);
      _isValid = true;
    }
  }

  void _onPlayerStateChanged(YoutubePlayerValue value) {
    if (!_markedWatched && value.playerState == PlayerState.ended) {
      _onVideoEnded();
    }
  }

  void _onVideoEnded() {
    _markedWatched = true;
    if (mounted) Navigator.of(context).pop();
  }

  void _markVideoAsWatched({bool shouldPopOnSuccess = true}) {
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
    _controllerSubscription?.cancel();
    _controller?.close();
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

    return YoutubePlayerScaffold(
      controller: controller,
      aspectRatio: 16 / 9,
      builder: (context, player) => Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                width: 100,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.grey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  widget.lesson.lessonTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
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
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: player,
              ),
              _buildPlayerControls(controller),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: AppButton(
                  onPressed: () {
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

  Widget _buildPlayerControls(YoutubePlayerController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          YoutubeValueBuilder(
            controller: controller,
            builder: (context, value) {
              final isPlaying = value.playerState == PlayerState.playing;
              return IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                  color: Colors.blueAccent,
                  size: 28,
                ),
                onPressed: () {
                  isPlaying ? controller.pauseVideo() : controller.playVideo();
                },
              );
            },
          ),
          _buildPlaybackSpeedButton(controller),
          YoutubeValueBuilder(
            controller: controller,
            buildWhen: (oldValue, newValue) =>
                oldValue.fullScreenOption != newValue.fullScreenOption,
            builder: (context, value) {
              final isFull = value.fullScreenOption.enabled;
              return IconButton(
                icon: Icon(
                  isFull ? Icons.fullscreen_exit : Icons.fullscreen,
                  color: Colors.blueGrey.shade700,
                  size: 24,
                ),
                onPressed: () => controller.toggleFullScreen(lock: false),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlaybackSpeedButton(YoutubePlayerController controller) {
    return YoutubeValueBuilder(
      controller: controller,
      builder: (context, value) {
        final currentRate = value.playbackRate;
        String formatRate(double rate) {
          final isInt = rate.truncateToDouble() == rate;
          return isInt ? rate.toStringAsFixed(0) : rate.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '');
        }

        return PopupMenuButton<double>(
          tooltip: 'Playback speed',
          onSelected: (rate) {
            if (rate != currentRate) controller.setPlaybackRate(rate);
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
              mainAxisSize: MainAxisSize.min,
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
