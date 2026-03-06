import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:brand_online/authorization/entity/RoadMapResponse.dart';
import 'package:brand_online/roadMap/ui/screen/web_view_page.dart';
import 'package:brand_online/roadMap/ui/widget/materials_widget.dart';
import 'package:brand_online/roadMap/ui/widget/youtube_embed_stub.dart'
    if (dart.library.html) 'package:brand_online/roadMap/ui/widget/youtube_embed_web.dart' as youtube_embed;
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
  String? _webVideoId;
  static const List<double> _playbackRates = [1.0, 1.25, 1.5, 1.75, 2.0];
  final ValueNotifier<bool> _isMuted = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    final videoId = _extractVideoId(widget.videoSolutionUrl);
    if (videoId.isEmpty) return;

    if (kIsWeb) {
      _webVideoId = videoId;
      return;
    }

    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        mute: false,
        loop: true,
        showControls: false,
        showFullscreenButton: false,
        enableCaption: false,
        showVideoAnnotations: false,
        strictRelatedVideos: true,
        pointerEvents: PointerEvents.none,
      ),
    );
    _controllerSubscription = _controller!.listen(_onPlayerStateChanged);
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
    final cleanUrl = url.split('?').first;
    final regExp = RegExp(r'(?:v=|\/|embed\/|youtu\.be\/)([A-Za-z0-9_-]{11})');
    final match = regExp.firstMatch(cleanUrl);
    return match?.group(1) ?? '';
  }

  @override
  void dispose() {
    _controllerSubscription?.cancel();
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final webVideoId = _webVideoId;

    if (kIsWeb && webVideoId != null) {
      final width = MediaQuery.of(context).size.width;
      final aspectRatio = width > 600 ? 16 / 4 : 16 / 12;
      final playerHeight = width / aspectRatio;
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                  SizedBox(
                    width: width,
                    height: playerHeight,
                    child: youtube_embed.YoutubeEmbedWeb(
                      videoId: webVideoId,
                      aspectRatio: aspectRatio,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (widget.lesson.materials.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.only(left: 15),
                      child: Text(
                        "Сабақтың материалдары",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
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
                  const SizedBox(height: 24),
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
                        onPressed: () => _markVideoAsWatched(),
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
        ),
      );
    }

    if (controller == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Видео недоступно',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Видео сілтемесі дұрыс емес. Артқа қайтып қайта көріңіз.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).maybePop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    'Артқа қайту',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final aspectRatio =
        MediaQuery.of(context).size.width > 600 ? 16 / 4 : 16 / 12;

    return YoutubePlayerScaffold(
      controller: controller,
      aspectRatio: aspectRatio,
      builder: (context, player) => Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                  Stack(
                    children: [
                      player,
                      Positioned.fill(
                        child: AbsorbPointer(
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildPlayerControls(controller),
                  const SizedBox(height: 20),
                  if (widget.lesson.materials.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.only(left: 15),
                      child: Text(
                        "Сабақтың материалдары",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
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
                  const SizedBox(height: 24),
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
                        onPressed: () => _markVideoAsWatched(),
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
        ),
      ),
    );
  }

  Widget _buildPlayerControls(YoutubePlayerController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPositionSlider(controller),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                ValueListenableBuilder<bool>(
                  valueListenable: _isMuted,
                  builder: (context, isMuted, _) {
                    return IconButton(
                      iconSize: 22,
                      icon: Icon(
                        isMuted ? Icons.volume_off : Icons.volume_up,
                        color: Colors.blueGrey.shade700,
                      ),
                      onPressed: () {
                        _isMuted.value = !isMuted;
                        if (isMuted) {
                          controller.unMute();
                        } else {
                          controller.mute();
                        }
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
          ],
        ),
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

  Widget _buildPositionSlider(YoutubePlayerController controller) {
    double sliderValue = 0.0;
    return StreamBuilder<YoutubeVideoState>(
      stream: controller.videoStateStream,
      initialData: const YoutubeVideoState(),
      builder: (context, snapshot) {
        final position = snapshot.data?.position ?? Duration.zero;
        final duration = controller.metadata.duration;
        final totalSeconds = duration.inSeconds;
        sliderValue = totalSeconds == 0
            ? 0.0
            : (position.inSeconds / totalSeconds).clamp(0.0, 1.0);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StatefulBuilder(
              builder: (context, setState) {
                return Slider(
                  value: sliderValue,
                  min: 0,
                  max: 1,
                  onChanged: totalSeconds == 0
                      ? null
                      : (value) {
                          sliderValue = value;
                          setState(() {});
                          controller.seekTo(
                            seconds: (sliderValue * totalSeconds).toDouble(),
                            allowSeekAhead: true,
                          );
                        },
                );
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(position),
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                Text(
                  _formatDuration(duration),
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
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
}
