import 'dart:async';

import 'package:brand_online/core/app_colors.dart';
import 'package:brand_online/core/text_styles.dart';
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
  youtube_embed.YoutubeEmbedWebController? _webController;
  static const List<double> _playbackRates = [1.0, 1.25, 1.5, 1.75, 2.0];
  final ValueNotifier<bool> _isMuted = ValueNotifier(false);
  bool _isMobileSliderDragging = false;
  double _mobileSliderValue = 0.0;
  bool _isWebSliderDragging = false;
  double _webSliderValue = 0.0;
  bool _isPlayerExpanded = false;

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
      _webController = youtube_embed.YoutubeEmbedWebController();
      return;
    }

    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: false,
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
    _webController?.dispose();
    _isMuted.dispose();
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
      final screenHeight = MediaQuery.of(context).size.height;
      final aspectRatio = width > 600 ? 16 / 4 : 16 / 12;
      final playerHeight = _isPlayerExpanded
          ? (screenHeight - 190).clamp(260.0, screenHeight)
          : width / aspectRatio;
      return Scaffold(
        appBar: AppBar(title: Text(widget.title, style: TextStyles.medium(AppColors.black),)),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: _isPlayerExpanded
                ? const NeverScrollableScrollPhysics()
                : const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Stack(
                    children: [
                      SizedBox(
                        width: width,
                        height: playerHeight,
                        child: youtube_embed.YoutubeEmbedWeb(
                          videoId: webVideoId,
                          aspectRatio: aspectRatio,
                          fillParent: _isPlayerExpanded,
                          controller: _webController,
                        ),
                      ),
                      Positioned.fill(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {},
                          onDoubleTap: () {},
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_webController != null) _buildWebPlayerControls(_webController!),
                  if (!_isPlayerExpanded) ...[
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: AppButton(
                        text: "ТҮСІНІКТІ",
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                    ),
                  ],
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
      builder: (context, player) {
        final screenHeight = MediaQuery.of(context).size.height;
        final maxPlayerHeight = _isPlayerExpanded
            ? (screenHeight - 210).clamp(260.0, screenHeight)
            : screenHeight * 0.42;
        return Scaffold(
          appBar: AppBar(title: Text(widget.title)),
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: maxPlayerHeight),
                  child: Stack(
                    children: [
                      IgnorePointer(child: player),
                      Positioned.fill(
                        child: AbsorbPointer(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {},
                            onDoubleTap: () {},
                            onLongPress: () {},
                            child: const SizedBox.expand(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _buildPlayerControls(controller),
                const SizedBox(height: 12),
                if (!_isPlayerExpanded)
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 24),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                              child: AppButton(
                                text: "ТҮСІНІКТІ",
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (_isPlayerExpanded) const Spacer(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayerControls(YoutubePlayerController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPositionSlider(controller),
            const SizedBox(height: 6),
            Row(
              children: [
                const SizedBox(width: 44),
                Expanded(
                  child: Center(
                    child: YoutubeValueBuilder(
                      controller: controller,
                      builder: (context, value) {
                        final isPlaying = value.playerState == PlayerState.playing;
                        return _buildRoundControlButton(
                          onTap: () {
                            isPlaying
                                ? controller.pauseVideo()
                                : controller.playVideo();
                          },
                          icon: isPlaying ? Icons.pause : Icons.play_arrow,
                        );
                      },
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPlaybackSpeedButton(controller),
                    _buildIconActionButton(
                      icon: _isPlayerExpanded ? Icons.fullscreen_exit : Icons.fullscreen,
                      onPressed: () {
                        setState(() {
                          _isPlayerExpanded = !_isPlayerExpanded;
                        });
                      },
                    ),
                  ],
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
                    '${formatRate(rate)}x',
                    style: TextStyle(
                      fontWeight: rate == currentRate ? FontWeight.w600 : FontWeight.normal,
                      color: rate == currentRate ? Colors.blueAccent : Colors.black87,
                    ),
                  ),
                ),
              )
              .toList(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Text(
              '${formatRate(currentRate)}x',
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWebPlaybackSpeedButton(youtube_embed.YoutubeEmbedWebController controller) {
    return ValueListenableBuilder<double>(
      valueListenable: controller.playbackRateNotifier,
      builder: (context, currentRate, _) {
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
                    '${formatRate(rate)}x',
                    style: TextStyle(
                      fontWeight: rate == currentRate ? FontWeight.w600 : FontWeight.normal,
                      color: rate == currentRate ? Colors.blueAccent : Colors.black87,
                    ),
                  ),
                ),
              )
              .toList(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Text(
              '${formatRate(currentRate)}x',
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWebPlayerControls(youtube_embed.YoutubeEmbedWebController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ValueListenableBuilder<double>(
              valueListenable: controller.progressNotifier,
              builder: (context, progressValue, _) {
                final sliderValue = _isWebSliderDragging
                    ? _webSliderValue.clamp(0.0, 1.0)
                    : progressValue.clamp(0.0, 1.0);
                return SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.blue,
                    inactiveTrackColor: const Color(0xFFE0E0E0),
                    trackHeight: 3,
                    thumbColor: Colors.blue,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayColor: Colors.blue.withOpacity(0.15),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                  ),
                  child: Slider(
                    value: sliderValue,
                    min: 0,
                    max: 1,
                    onChangeStart: (value) {
                      setState(() {
                        _isWebSliderDragging = true;
                        _webSliderValue = value;
                      });
                    },
                    onChanged: (value) {
                      setState(() {
                        _webSliderValue = value;
                      });
                    },
                    onChangeEnd: (value) {
                      controller.seekToProgress(value);
                      setState(() {
                        _isWebSliderDragging = false;
                      });
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const SizedBox(width: 44),
                Expanded(
                  child: Center(
                    child: ValueListenableBuilder<bool>(
                      valueListenable: controller.isPlayingNotifier,
                      builder: (context, isPlaying, _) {
                        return _buildRoundControlButton(
                          onTap: () {
                            if (isPlaying) {
                              controller.pause();
                            } else {
                              controller.play();
                            }
                          },
                          icon: isPlaying ? Icons.pause : Icons.play_arrow,
                        );
                      },
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildWebPlaybackSpeedButton(controller),
                    _buildIconActionButton(
                      icon: _isPlayerExpanded ? Icons.fullscreen_exit : Icons.fullscreen,
                      onPressed: () {
                        setState(() {
                          _isPlayerExpanded = !_isPlayerExpanded;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundControlButton({
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(32),
        onTap: onTap,
        child: Ink(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFF1F3F5),
            border: Border.all(color: const Color(0xFFE0E3E7)),
          ),
          child: Icon(icon, color: Colors.black87, size: 34),
        ),
      ),
    );
  }

  Widget _buildIconActionButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      iconSize: 28,
      splashRadius: 22,
      icon: Icon(icon, color: Colors.black87),
      onPressed: onPressed,
    );
  }

  Widget _buildPositionSlider(YoutubePlayerController controller) {
    return YoutubeValueBuilder(
      controller: controller,
      builder: (context, snapshot) {
        final value = snapshot;
        final duration = value.metaData.duration;
        final totalSeconds = duration.inSeconds.toDouble();

        return StreamBuilder<YoutubeVideoState>(
          stream: controller.videoStateStream,
          initialData: const YoutubeVideoState(),
          builder: (context, streamSnapshot) {
            final position = streamSnapshot.data?.position ?? Duration.zero;
            final liveValue = totalSeconds <= 0
                ? 0.0
                : (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
            final sliderValue = _isMobileSliderDragging
                ? _mobileSliderValue.clamp(0.0, 1.0)
                : liveValue;

            return SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.blue,
                inactiveTrackColor: const Color(0xFFE0E0E0),
                trackHeight: 3,
                thumbColor: Colors.blue,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayColor: Colors.blue.withOpacity(0.15),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              ),
              child: Slider(
                value: sliderValue,
                min: 0,
                max: 1,
                onChangeStart: totalSeconds <= 0
                    ? null
                    : (v) {
                        setState(() {
                          _isMobileSliderDragging = true;
                          _mobileSliderValue = v;
                        });
                      },
                onChanged: totalSeconds <= 0
                    ? null
                    : (v) {
                        setState(() {
                          _mobileSliderValue = v;
                        });
                      },
                onChangeEnd: totalSeconds <= 0
                    ? null
                    : (v) {
                        controller.seekTo(
                          seconds: v * totalSeconds,
                          allowSeekAhead: true,
                        );
                        setState(() {
                          _isMobileSliderDragging = false;
                        });
                      },
              ),
            );
          },
        );
      },
    );
  }
}
