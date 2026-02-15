import 'dart:async';

import 'package:brand_online/roadMap/ui/screen/Math1Screen.dart';
import 'package:brand_online/roadMap/ui/screen/web_view_page.dart';
import 'package:brand_online/roadMap/ui/widget/materials_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../../authorization/entity/RoadMapResponse.dart';
import '../../service/youtube_service.dart';

class YoutubeScreen extends StatefulWidget {
  final Lesson lesson;

  const YoutubeScreen({super.key, required this.lesson});

  @override
  State<YoutubeScreen> createState() => _YoutubeScreenState();
}

class _YoutubeScreenState extends State<YoutubeScreen> with WidgetsBindingObserver {
  YoutubePlayerController? _controller;
  StreamSubscription<YoutubePlayerValue>? _controllerSubscription;
  bool _markedWatched = false;
  final _noScreenshot = NoScreenshot.instance;
  static const List<double> _playbackRates = [1.0, 1.25, 1.5, 1.75, 2.0];
  final ValueNotifier<bool> _isMuted = ValueNotifier(false);

  // screenshot
  void disableScreenshot() async {
    bool result = await _noScreenshot.screenshotOff();
    debugPrint('Screenshot Off: $result');
  }

  void enableScreenshot() async {
    bool result = await _noScreenshot.screenshotOn();
    debugPrint('Enable Screenshot: $result');
  }

  @override
  void initState() {
    super.initState();
    disableScreenshot();
    WidgetsBinding.instance.addObserver(this);

    final videoId = _extractVideoId(widget.lesson.videoUrl);
    debugPrint('Extracted Video ID: $videoId');

    if (videoId.isEmpty) {
      debugPrint('Unable to extract YouTube video ID from URL: ${widget.lesson.videoUrl}');
      return;
    }

    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        mute: false,
        loop: false,
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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controllerSubscription?.cancel();
    _controller?.close();
    _isMuted.dispose();
    super.dispose();
  }

  String _extractVideoId(String url) {
  debugPrint('Original URL: $url');
  
  final cleanUrl = url.split('?').first;
  debugPrint('Clean URL: $cleanUrl');
  
  final regExp = RegExp(r'(?:v=|\/|embed\/|youtu\.be\/)([A-Za-z0-9_-]{11})');
  final match = regExp.firstMatch(cleanUrl);
  
  final videoId = match?.group(1) ?? '';
  debugPrint('Extracted Video ID: $videoId');
  
  return videoId;
}

  void _onPlayerStateChanged(YoutubePlayerValue value) {
    if (!_markedWatched && value.playerState == PlayerState.ended) {
      _markVideoAsWatched();
    }
  }

  void _markVideoAsWatched({bool shouldPopOnSuccess = true}) async {
    if (_markedWatched) return;
    _markedWatched = true;
    YoutubeService().videoWatched(widget.lesson.lessonId).then((res) {
      if (res != null && res.message == "Lesson marked as watched.") {
        widget.lesson.videoWatched = true;
        // if (shouldPopOnSuccess && mounted) {
        //   Navigator.of(context).pop(true);
        // }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
  final controller = _controller;
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
                'Не удалось определить ссылку на ролик. Попробуйте позже или обратитесь в поддержку.',
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
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
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
                // Player with protected top area to prevent opening channel.
                Stack(
                  children: [
                    player,
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 48,
                      child: IgnorePointer(
                        child: Container(color: Colors.transparent),
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
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
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
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 10),
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.lesson.materials.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () async {
                              String privacyUrl =
                                  widget.lesson.materials[index].url;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => WebViewPage(
                                    url: privacyUrl,
                                    isAction: false,
                                    lessonId: 0,
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15, vertical: 0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        _markVideoAsWatched(shouldPopOnSuccess: false);
                        enableScreenshot();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Math1Screen(
                              initialScrollOffset: 20,
                              lessonId: widget.lesson.lessonId,
                              groupId: 1,
                              cashbackActive:
                                  widget.lesson.cashbackActive,
                              isCash: false,
                              lesson: widget.lesson,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        "Тестке өту",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15, vertical: 0),
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
                        Navigator.of(context).pop(true);
                        enableScreenshot();
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
      ),
    ),
  );
  }
  /// External controls: progress, time, play/pause, mute, speed.
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
                // Play / pause
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
                        isPlaying
                            ? controller.pauseVideo()
                            : controller.playVideo();
                      },
                    );
                  },
                ),
                // Mute / unmute
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
                // Speed selector
                _buildPlaybackSpeedButton(controller),
                // Fullscreen toggle
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
                      onPressed: () {
                        controller.toggleFullScreen(lock: false);
                      },
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
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  _formatDuration(duration),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
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
    if (hours > 0) {
      return "$hours:$minutes:$seconds";
    }
    return "$minutes:$seconds";
  }
}
