import 'dart:async';

import 'package:flutter/material.dart';
import 'package:brand_online/authorization/entity/RoadMapResponse.dart';
import 'package:brand_online/roadMap/ui/screen/web_view_page.dart';
import 'package:brand_online/roadMap/ui/widget/materials_widget.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class YoutubeUrlScreen extends StatefulWidget {
  final String videoSolutionUrl;
  final Lesson lesson;

  const YoutubeUrlScreen({super.key, required this.videoSolutionUrl, required this.lesson});

  @override
  State<YoutubeUrlScreen> createState() => _YoutubeUrlScreenState();
}

class _YoutubeUrlScreenState extends State<YoutubeUrlScreen> {
  YoutubePlayerController? _controller;
  StreamSubscription<YoutubePlayerValue>? _controllerSubscription;
  bool _markedWatched = false;
  bool _isValid = false;
  static const List<double> _playbackRates = [1.0, 1.5, 2.0];

  @override
  void initState() {
    super.initState();
    final videoId = _extractVideoId(widget.videoSolutionUrl);
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
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 24, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  "Видео сабақ",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
              player,
              _buildPlayerControls(controller),
              const SizedBox(height: 20),
              if (widget.lesson.materials.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.only(left: 15),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Сабақтың материалдары",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: SizedBox(
                    height: 150,
                    width: double.infinity,
                    child: ListView.separated(
                      separatorBuilder: (context, index) => const SizedBox(width: 10),
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.lesson.materials.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            final privacyUrl = widget.lesson.materials[index].url;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => WebViewPage(
                                  url: privacyUrl,
                                  isAction: false,
                                  lessonId: widget.lesson.lessonId,
                                  actionId: 0,
                                ),
                              ),
                            );
                          },
                          child: MaterialsWidget(
                            title: widget.lesson.materials[index].name,
                            url: widget.lesson.materials[index].url,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
              const Spacer(),
              const SizedBox(height: 20),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      _markVideoAsWatched();
                    },
                    child: const Text(
                      "Түсінікті",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            YoutubeValueBuilder(
              controller: controller,
              builder: (context, value) {
                final isPlaying = value.playerState == PlayerState.playing;
                return IconButton(
                  iconSize: 24,
                  icon: Icon(
                    isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                    color: Colors.blueAccent,
                  ),
                  onPressed: () {
                    isPlaying ? controller.pauseVideo() : controller.playVideo();
                  },
                );
              },
            ),
            Expanded(child: _buildPositionSlider(controller)),
            _buildPlaybackSpeedButton(controller),
            YoutubeValueBuilder(
              controller: controller,
              buildWhen: (oldValue, newValue) =>
                  oldValue.fullScreenOption != newValue.fullScreenOption,
              builder: (context, value) {
                final isFull = value.fullScreenOption.enabled;
                return IconButton(
                  iconSize: 22,
                  icon: Icon(
                    isFull ? Icons.fullscreen_exit : Icons.fullscreen,
                    color: Colors.blueGrey.shade700,
                  ),
                  onPressed: () => controller.toggleFullScreen(lock: false),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionSlider(YoutubePlayerController controller) {
    return StreamBuilder<YoutubeVideoState>(
      stream: controller.videoStateStream,
      initialData: const YoutubeVideoState(),
      builder: (context, snapshot) {
        final position = snapshot.data?.position ?? Duration.zero;
        final duration = controller.metadata.duration;
        final totalSeconds = duration.inSeconds;
        final sliderValue = totalSeconds == 0
            ? 0.0
            : (position.inSeconds / totalSeconds).clamp(0.0, 1.0);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Slider(
              value: sliderValue,
              min: 0,
              max: 1,
              onChanged: totalSeconds == 0
                  ? null
                  : (value) {
                      controller.seekTo(
                        seconds: (value * totalSeconds).toDouble(),
                        allowSeekAhead: true,
                      );
                    },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatDuration(position), style: const TextStyle(fontSize: 12, color: Colors.black54)),
                Text(_formatDuration(duration), style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ],
        );
      },
    );
  }

  String _formatDuration(Duration d) {
    if (d == Duration.zero) return "00:00";
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = d.inHours;
    if (hours > 0) return "$hours:$minutes:$seconds";
    return "$minutes:$seconds";
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
