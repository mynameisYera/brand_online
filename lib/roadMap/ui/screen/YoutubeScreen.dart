import 'dart:async';

import 'package:brand_online/core/app_colors.dart';
import 'package:brand_online/core/text_styles.dart';
import 'package:brand_online/core/widgets/app_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:brand_online/roadMap/ui/screen/Math1Screen.dart';
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
  StreamSubscription<YoutubePlayerValue>? _playerSubscription;
  bool _markedWatched = false;
  final _noScreenshot = NoScreenshot.instance;
  static const List<double> _playbackRates = [1.0, 1.25, 1.5, 1.75, 2.0];
  Duration _videoDuration = Duration.zero;
  Duration _lastPosition = Duration.zero;
  bool _isDragging = false;
  double? _dragValue;

  // screenshot
  void disableScreenshot() async {
    if (kIsWeb) return;
    bool result = await _noScreenshot.screenshotOff();
    debugPrint('Screenshot Off: $result');
  }

  void enableScreenshot() async {
    if (kIsWeb) return;
    bool result = await _noScreenshot.screenshotOn();
    debugPrint('Enable Screenshot: $result');
  }

  @override
void initState() {
  super.initState();
  if (!kIsWeb) {
    disableScreenshot();
  }
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
      showControls: false,
      showFullscreenButton: false,
      enableCaption: false,
      enableKeyboard: false,
      pointerEvents: PointerEvents.none,
      showVideoAnnotations: false,
      loop: false,
      strictRelatedVideos: true,
    ),
  );
  _playerSubscription = _controller?.listen(_onPlayerValueChanged);
  _loadDuration();
}

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _playerSubscription?.cancel();
    _controller?.close();
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

  void _onPlayerValueChanged(YoutubePlayerValue value) {
    if (_videoDuration == Duration.zero &&
        (value.playerState == PlayerState.playing || value.playerState == PlayerState.paused)) {
      _loadDuration();
    }
    if (!_markedWatched && value.playerState == PlayerState.ended) {
      _markVideoAsWatched();
    }
  }

  Future<void> _loadDuration() async {
    final controller = _controller;
    if (controller == null) return;
    final seconds = await controller.duration;
    if (!mounted || seconds <= 0) return;
    setState(() {
      _videoDuration = Duration(seconds: seconds.round());
    });
  }

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
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

  return Scaffold(
    backgroundColor: Colors.black,
    body: SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              widget.lesson.lessonTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: IgnorePointer(
              ignoring: true,
              child: YoutubePlayer(controller: controller),
            ),
          ),
          const SizedBox(height: 8),
          _buildPlaybackControls(controller),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: AppButton(
              text: "Тестке өту",
              onPressed: () {
                _markVideoAsWatched(shouldPopOnSuccess: false);
                _playerSubscription?.cancel();
                _controller?.close();
                _controller = null;
                enableScreenshot();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Math1Screen(
                      initialScrollOffset: 20,
                      lessonId: widget.lesson.lessonId,
                      groupId: 1,
                      cashbackActive: widget.lesson.cashbackActive,
                      isCash: false,
                      lesson: widget.lesson,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: TextButton(
              onPressed: () {
                _markVideoAsWatched();
                Navigator.of(context).pop(true);
                enableScreenshot();
              },
              child: Text("Артқа қайту", style: TextStyles.medium(AppColors.primaryBlue)),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
  }

  Widget _buildPlaybackControls(YoutubePlayerController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: YoutubeValueBuilder(
        controller: controller,
        builder: (context, value) {
          String formatRate(double rate) {
            final isInt = rate.truncateToDouble() == rate;
            return isInt ? rate.toStringAsFixed(0) : rate.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '');
          }

          return StreamBuilder<YoutubeVideoState>(
            stream: controller.videoStateStream,
            builder: (context, snapshot) {
              final snapshotPosition = snapshot.data?.position;
              if (snapshotPosition != null) {
                _lastPosition = snapshotPosition;
              }
              final position = snapshotPosition ?? _lastPosition;
              final durationSeconds = _videoDuration.inSeconds.toDouble();
              final currentSeconds = _isDragging
                  ? (_dragValue ?? position.inSeconds.toDouble())
                  : position.inSeconds.toDouble();
              final maxSeconds = durationSeconds > 0 ? durationSeconds : 1.0;
              final isPlaying = value.playerState == PlayerState.playing;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        _formatDuration(Duration(seconds: currentSeconds.round())),
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Expanded(
                        child: Slider(
                          value: currentSeconds.clamp(0, maxSeconds).toDouble(),
                          min: 0,
                          max: maxSeconds,
                          activeColor: Colors.blueAccent,
                          inactiveColor: Colors.white30,
                          onChanged: durationSeconds <= 0
                              ? null
                              : (value) {
                                  setState(() {
                                    _isDragging = true;
                                    _dragValue = value;
                                  });
                                },
                          onChangeEnd: durationSeconds <= 0
                              ? null
                              : (value) {
                                  controller.seekTo(seconds: value, allowSeekAhead: true);
                                  setState(() {
                                    _isDragging = false;
                                    _dragValue = null;
                                  });
                                },
                        ),
                      ),
                      Text(
                        _formatDuration(_videoDuration),
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (isPlaying) {
                            controller.pauseVideo();
                          } else {
                            controller.playVideo();
                          }
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      PopupMenuButton<double>(
                        tooltip: 'Playback speed',
                        onSelected: (rate) {
                          if (rate != value.playbackRate) {
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
                                    fontWeight: rate == value.playbackRate ? FontWeight.w600 : FontWeight.normal,
                                    color: rate == value.playbackRate ? Colors.blueAccent : Colors.black87,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.speed, color: Colors.white, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                'x${formatRate(value.playbackRate)}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}