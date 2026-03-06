import 'dart:async';

import 'package:brand_online/core/widgets/app_button_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:brand_online/roadMap/ui/widget/youtube_embed_stub.dart'
    if (dart.library.html) 'package:brand_online/roadMap/ui/widget/youtube_embed_web.dart' as youtube_embed;
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
  StreamSubscription<YoutubePlayerValue>? _controllerSubscription;
  String? _webVideoId;
  static const List<double> _playbackRates = [1.0, 1.25, 1.5, 1.75, 2.0];
  final ValueNotifier<bool> _isMuted = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    final videoId = _extractVideoId(widget.url);
    if (videoId.isEmpty) {
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

    if (kIsWeb) {
      _webVideoId = videoId;
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
    _controllerSubscription = _controller!.listen((_) {});
  }

  @override
  void dispose() {
    _controllerSubscription?.cancel();
    _controller?.close();
    super.dispose();
  }

  String _extractVideoId(String url) {
    final cleanUrl = url.split('?').first;
    final regExp = RegExp(r'(?:v=|\/|embed\/|youtu\.be\/)([A-Za-z0-9_-]{11})');
    final match = regExp.firstMatch(cleanUrl);
    return match?.group(1) ?? '';
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
        appBar: AppBar(title: Text(widget.title)),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: width,
                    height: playerHeight,
                    child: youtube_embed.YoutubeEmbedWeb(
                      videoId: webVideoId,
                      aspectRatio: aspectRatio,
                    ),
                  ),
                  const SizedBox(height: 24),
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
        ),
      );
    }

    if (controller == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const SizedBox.shrink(),
      );
    }

    final aspectRatio =
        MediaQuery.of(context).size.width > 600 ? 16 / 4 : 16 / 12;

    return YoutubePlayerScaffold(
      controller: controller,
      aspectRatio: aspectRatio,
      builder: (context, player) => Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                  const SizedBox(height: 24),
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
