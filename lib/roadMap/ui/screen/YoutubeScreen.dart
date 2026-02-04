import 'dart:async';

import 'package:brand_online/core/app_colors.dart';
import 'package:brand_online/core/widgets/app_button_widget.dart';
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

  Future<void> _openFullPage(YoutubePlayerController controller) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _YoutubeFullPage(controller: controller),
      ),
    );
    if (!mounted) return;
    setState(() {});
    controller.playVideo();
  }

  void _markVideoAsWatched({bool shouldPopOnSuccess = true}) async {
    if (_markedWatched) return;
    _controller?.pauseVideo();
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
    final isWide = MediaQuery.of(context).size.width > 600;

    if (controller == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF6F7FB),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.redAccent, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      'Видео недоступно',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Не удалось определить ссылку на ролик. Попробуйте позже или обратитесь в поддержку.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Артқа қайту',
                          style: TextStyle(fontSize: 16, color: Colors.white),
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

    final aspectRatio = isWide ? 16 / 6 : 16 / 9;

    return YoutubePlayerScaffold(
      controller: controller,
      aspectRatio: aspectRatio,
      builder: (context, player) => Scaffold(
        backgroundColor: const Color(0xFFF6F7FB),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text(
                      widget.lesson.lessonTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 14,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Stack(
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
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPlayerControls(controller),
                  const SizedBox(height: 20),
                  if (widget.lesson.materials.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.only(left: 20),
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
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        height: 160,
                        width: double.infinity,
                        child: ListView.separated(
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 12),
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
                  // Padding(
                  //   padding:
                  //       const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  //   child: SizedBox(
                  //     width: double.infinity,
                  //     height: 52,
                  //     child: ElevatedButton(
                  //       style: ElevatedButton.styleFrom(
                  //         backgroundColor: Colors.lightBlue,
                  //         shape: RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.circular(14),
                  //         ),
                  //       ),
                  //       onPressed: () {
                  //         _markVideoAsWatched(shouldPopOnSuccess: false);
                  //         enableScreenshot();
                  //         Navigator.push(
                  //           context,
                  //           MaterialPageRoute(
                  //             builder: (context) => Math1Screen(
                  //               initialScrollOffset: 20,
                  //               lessonId: widget.lesson.lessonId,
                  //               groupId: 1,
                  //               cashbackActive: widget.lesson.cashbackActive,
                  //               isCash: false,
                  //               lesson: widget.lesson,
                  //             ),
                  //           ),
                  //         );
                  //       },
                  //       child: const Text(
                  //         "Тестке өту",
                  //         style: TextStyle(
                  //           color: Colors.white,
                  //           fontSize: 18,
                  //           fontWeight: FontWeight.bold,
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: AppButton(
                      text: "Тестке өту",
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
                                  cashbackActive: widget.lesson.cashbackActive,
                                  isCash: false,
                                  lesson: widget.lesson,
                                ),
                              ),
                            );
                          },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: TextButton(
                      child: Text("Артқа қайту", style: TextStyle(color: AppColors.primaryBlue, fontSize: 18),),
                      onPressed: () {
                          _markVideoAsWatched();
                          Navigator.of(context).pop(true);
                          enableScreenshot();
                        },
                    ),
                  ),
                  // Padding(
                  //   padding:
                  //       const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  //   child: SizedBox(
                  //     width: double.infinity,
                  //     height: 52,
                  //     child: ElevatedButton(
                  //       style: ElevatedButton.styleFrom(
                  //         backgroundColor: Colors.blue,
                  //         shape: RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.circular(14),
                  //         ),
                  //       ),
                  //       onPressed: () {
                  //         _markVideoAsWatched();
                  //         Navigator.of(context).pop(true);
                  //         enableScreenshot();
                  //       },
                  //       child: const Text(
                  //         "Түсінікті",
                  //         style: TextStyle(
                  //           color: Colors.white,
                  //           fontSize: 18,
                  //           fontWeight: FontWeight.bold,
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
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
                    return IconButton(
                      iconSize: 22,
                      icon: Icon(
                        Icons.fullscreen,
                        color: Colors.blueGrey.shade700,
                      ),
                      onPressed: () {
                        _openFullPage(controller);
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
                  thumbColor: AppColors.primaryBlue,
                  activeColor: AppColors.primaryBlue,
                  inactiveColor: Colors.grey.shade300,
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

class _YoutubeFullPage extends StatefulWidget {
  const _YoutubeFullPage({required this.controller});

  final YoutubePlayerController controller;

  @override
  State<_YoutubeFullPage> createState() => _YoutubeFullPageState();
}

class _YoutubeFullPageState extends State<_YoutubeFullPage> {
  static const List<double> _playbackRates = [1.0, 1.25, 1.5, 1.75, 2.0];
  final ValueNotifier<bool> _isMuted = ValueNotifier(false);

  @override
  void dispose() {
    _isMuted.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerScaffold(
      controller: widget.controller,
      aspectRatio: 16 / 9,
      builder: (context, player) => Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Center(child: player),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Material(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(24),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () => Navigator.of(context).pop(),
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(Icons.fullscreen_exit,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildFullControls(widget.controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullControls(YoutubePlayerController controller) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPositionSlider(controller),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              YoutubeValueBuilder(
                controller: controller,
                builder: (context, value) {
                  final isPlaying = value.playerState == PlayerState.playing;
                  return IconButton(
                    iconSize: 28,
                    icon: Icon(
                      isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_fill,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      isPlaying
                          ? controller.pauseVideo()
                          : controller.playVideo();
                    },
                  );
                },
              ),
              ValueListenableBuilder<bool>(
                valueListenable: _isMuted,
                builder: (context, isMuted, _) {
                  return IconButton(
                    iconSize: 24,
                    icon: Icon(
                      isMuted ? Icons.volume_off : Icons.volume_up,
                      color: Colors.white70,
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
              IconButton(
                iconSize: 26,
                icon: const Icon(Icons.fullscreen_exit, color: Colors.white70),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
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
          return isInt
              ? rate.toStringAsFixed(0)
              : rate.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '');
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
                      fontWeight: rate == currentRate
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: rate == currentRate
                          ? AppColors.primaryBlue
                          : Colors.black87,
                    ),
                  ),
                ),
              )
              .toList(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.speed, color: Colors.white, size: 18),
                const SizedBox(width: 4),
                Text(
                  'x${formatRate(currentRate)}',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
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
                  thumbColor: AppColors.primaryBlue,
                  activeColor: AppColors.primaryBlue,
                  inactiveColor: Colors.white24,
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
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
                Text(
                  _formatDuration(duration),
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
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