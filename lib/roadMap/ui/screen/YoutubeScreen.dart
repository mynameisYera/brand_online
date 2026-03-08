import 'dart:async';

import 'package:brand_online/core/app_colors.dart';
import 'package:brand_online/core/text_styles.dart';
import 'package:brand_online/core/widgets/app_button_widget.dart';
import 'package:brand_online/core/widgets/watermark_layer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:brand_online/roadMap/ui/screen/Math1Screen.dart';
import 'package:brand_online/roadMap/ui/screen/web_view_page.dart';
import 'package:brand_online/roadMap/ui/widget/materials_widget.dart';
import 'package:brand_online/roadMap/ui/widget/youtube_embed_stub.dart'
    if (dart.library.html) 'package:brand_online/roadMap/ui/widget/youtube_embed_web.dart' as youtube_embed;
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
  /// On web: videoId for iframe embed (controller is not used).
  String? _webVideoId;
  youtube_embed.YoutubeEmbedWebController? _webController;
  final _noScreenshot = NoScreenshot.instance;
  static const List<double> _playbackRates = [1.0, 1.25, 1.5, 1.75, 2.0];
  final ValueNotifier<bool> _isMuted = ValueNotifier(false);
  bool _isMobileSliderDragging = false;
  double _mobileSliderValue = 0.0;
  bool _isWebSliderDragging = false;
  double _webSliderValue = 0.0;
  bool _isPlayerExpanded = false;

  void _disableScreenshot() async {
    final result = await _noScreenshot.screenshotOff();
    debugPrint('Screenshot Off: $result');
  }

  void _enableScreenshot() async {
    final result = await _noScreenshot.screenshotOn();
    debugPrint('Screenshot On: $result');
  }

  @override
  void initState() {
    super.initState();
    _disableScreenshot();
    WidgetsBinding.instance.addObserver(this);

    final videoId = _extractVideoId(widget.lesson.videoUrl);
    debugPrint('Extracted Video ID: $videoId');

    if (videoId.isEmpty) {
      debugPrint('Unable to extract YouTube video ID from URL: ${widget.lesson.videoUrl}');
      return;
    }

    // On web, youtube_player_iframe triggers createPlatformNavigationDelegate which is not implemented.
    // Use native iframe embed instead so video plays on the page.
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

    _controllerSubscription = _controller!.listen(_onPlayerStateChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controllerSubscription?.cancel();
    _controller?.close();
    _webController?.dispose();
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
  final webVideoId = _webVideoId;

  // Web: embed YouTube via iframe on the page (no WebView).
  if (kIsWeb && webVideoId != null) {
    final width = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final aspectRatio = width > 600 ? 16 / 4 : 16 / 12;
    final playerHeight = _isPlayerExpanded
        ? (screenHeight - 190).clamp(260.0, screenHeight)
        : width / aspectRatio;
    return Scaffold(
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
                // Оверлей перехватывает клики — плеер не нажимается, управление только кнопками снизу.
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
                              final privacyUrl =
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
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: AppButton(
                      color: AppButtonColor.blue, 
                      text: "Тестке өту", 
                      onPressed: () {
                            _markVideoAsWatched(shouldPopOnSuccess: false);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AdaptiveWatermark(phone: "", userId: "", child: Math1Screen(
                                  initialScrollOffset: 20,
                                  lessonId: widget.lesson.lessonId,
                                  groupId: 1,
                                  cashbackActive:
                                      widget.lesson.cashbackActive,
                                  isCash: false,
                                  lesson: widget.lesson,
                                ),),
                              ),
                            );
                          },
                    ),
                ),
                const SizedBox(height: 10),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                //   child: SizedBox(
                //     width: double.infinity,
                //     height: 50,
                //     child: ElevatedButton(
                //       style: ElevatedButton.styleFrom(
                //         backgroundColor: Colors.white,
                //         shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(12),
                //         ),
                //       ),
                //       onPressed: () {
                //         _markVideoAsWatched();
                //         Navigator.of(context).pop(true);
                //         _enableScreenshot();
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
                Center(
                  child: InkWell(
                    onTap: () {
                      _markVideoAsWatched();
                      Navigator.of(context).pop(true);
                      _enableScreenshot();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: EdgeInsets.all(15),
                      child: Text("Артқа қайту", style: TextStyles.regular(AppColors.primaryBlue, fontSize: 16),),
                    ),
                  ),
                )
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
    builder: (context, player) {
      final screenHeight = MediaQuery.of(context).size.height;
      final maxPlayerHeight = _isPlayerExpanded
          ? (screenHeight - 210).clamp(260.0, screenHeight)
          : screenHeight * 0.42;
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxPlayerHeight),
                child: ClipRect(
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.hardEdge,
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
              ),
              const SizedBox(height: 8),
              _buildPlayerControls(controller),
              const SizedBox(height: 12),
            if (!_isPlayerExpanded)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                      const SizedBox(height: 24),
                    ],
                    AppButton(
                      color: AppButtonColor.blue, 
                      text: "Тестке өту", 
                      onPressed: () {
                            _markVideoAsWatched(shouldPopOnSuccess: false);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AdaptiveWatermark(phone: "", userId: "", child: Math1Screen(
                                  initialScrollOffset: 20,
                                  lessonId: widget.lesson.lessonId,
                                  groupId: 1,
                                  cashbackActive:
                                      widget.lesson.cashbackActive,
                                  isCash: false,
                                  lesson: widget.lesson,
                                ),),
                              ),
                            );
                          },
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(
                    //       horizontal: 15, vertical: 0),
                    //   child: SizedBox(
                    //     width: double.infinity,
                    //     height: 50,
                    //     child: ElevatedButton(
                    //       style: ElevatedButton.styleFrom(
                    //         backgroundColor: Colors.lightBlue,
                    //         shape: RoundedRectangleBorder(
                    //           borderRadius: BorderRadius.circular(12),
                    //         ),
                    //       ),
                    //       onPressed: () {
                    //         _markVideoAsWatched(shouldPopOnSuccess: false);
                    //         Navigator.push(
                    //           context,
                    //           MaterialPageRoute(
                    //             builder: (context) => AdaptiveWatermark(phone: "", userId: "", child: Math1Screen(
                    //               initialScrollOffset: 20,
                    //               lessonId: widget.lesson.lessonId,
                    //               groupId: 1,
                    //               cashbackActive:
                    //                   widget.lesson.cashbackActive,
                    //               isCash: false,
                    //               lesson: widget.lesson,
                    //             ),),
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
            if (_isPlayerExpanded) const Spacer(),
          ],
        ),
      ),
    );
    },
  );
  }

  /// Контролы снизу: ползунок и play/pause. Кнопки самого YouTube отключены (params + оверлей).
  // Widget _buildPlayerControls(YoutubePlayerController controller) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
  //     child: Container(
  //       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
  //       decoration: BoxDecoration(
  //         color: Colors.grey.shade100,
  //         borderRadius: BorderRadius.circular(10),
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.black.withOpacity(0.05),
  //             blurRadius: 5,
  //             offset: const Offset(0, 1),
  //           ),
  //         ],
  //       ),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.stretch,
  //         children: [
  //           _buildPositionSlider(controller),
  //           const SizedBox(height: 4),
  //           Center(
  //             child: YoutubeValueBuilder(
  //               controller: controller,
  //               builder: (context, value) {
  //                 final isPlaying = value.playerState == PlayerState.playing;
  //                 return IconButton(
  //                   iconSize: 40,
  //                   icon: Icon(
  //                     isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
  //                     color: Colors.blueAccent,
  //                   ),
  //                   onPressed: () {
  //                     isPlaying
  //                         ? controller.pauseVideo()
  //                         : controller.playVideo();
  //                   },
  //                 );
  //               },
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

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

  Widget _buildPositionSlider(YoutubePlayerController controller) {
    return YoutubeValueBuilder(
      controller: controller,
      builder: (context, value) {
        final duration = value.metaData.duration;
        final totalSeconds = duration.inSeconds.toDouble();

        return StreamBuilder<YoutubeVideoState>(
          stream: controller.videoStateStream,
          initialData: const YoutubeVideoState(),
          builder: (context, snapshot) {
            final position = snapshot.data?.position ?? Duration.zero;
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
                    : (value) {
                        setState(() {
                          _isMobileSliderDragging = true;
                          _mobileSliderValue = value;
                        });
                      },
                onChanged: totalSeconds <= 0
                    ? null
                    : (value) {
                        setState(() {
                          _mobileSliderValue = value;
                        });
                      },
                onChangeEnd: totalSeconds <= 0
                    ? null
                    : (value) {
                        controller.seekTo(
                          seconds: value * totalSeconds,
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