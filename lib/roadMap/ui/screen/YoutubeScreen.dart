import 'dart:async';

import 'package:brand_online/core/app_colors.dart';
import 'package:brand_online/core/widgets/app_button_widget.dart';
import 'package:brand_online/roadMap/ui/screen/Math1Screen.dart';
import 'package:brand_online/roadMap/ui/screen/web_view_page.dart';
import 'package:brand_online/roadMap/ui/widget/materials_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../../authorization/entity/RoadMapResponse.dart';
import '../../service/youtube_service.dart';

class YoutubeScreen extends StatefulWidget {
  final Lesson lesson;
  /// URL видео с бэкенда (урок или action). Если задан, используется вместо lesson.videoUrl.
  final String? videoUrlOverride;

  const YoutubeScreen({super.key, required this.lesson, this.videoUrlOverride});

  @override
  State<YoutubeScreen> createState() => _YoutubeScreenState();
}

class _YoutubeScreenState extends State<YoutubeScreen> with WidgetsBindingObserver {
  YoutubePlayerController? _controller;
  StreamSubscription<YoutubePlayerValue>? _controllerSubscription;
  bool _markedWatched = false;
  bool _initAttempted = false;
  bool _invalidVideoId = false;
  bool _initTimedOut = false;
  bool _navigatedToTest = false;
  final _noScreenshot = NoScreenshot.instance;
  final ValueNotifier<bool> _isMuted = ValueNotifier(false);

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
    disableScreenshot();
    WidgetsBinding.instance.addObserver(this);
    // На веб не используем YoutubePlayerController — iframe часто не работает после деплоя.
    if (!kIsWeb) _initController();
  }

  void _initController() {
    final videoUrl = widget.videoUrlOverride ?? widget.lesson.videoUrl;
    final videoId = _extractVideoId(videoUrl);
    if (videoId.isEmpty) {
      debugPrint('YoutubeScreen: no video ID (video_url: "$videoUrl")');
      _invalidVideoId = true;
      _initAttempted = true;
      if (mounted) setState(() {});
      return;
    }

    try {
      _controllerSubscription?.cancel();
      _controller?.close();
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
      _controllerSubscription = _controller?.listen(_onPlayerStateChanged);
      _invalidVideoId = false;
      _initTimedOut = false;
      _initAttempted = true;
    } catch (e, st) {
      debugPrint('YoutubeScreen: init failed: $e');
      debugPrint('$st');
      _invalidVideoId = true;
      _initAttempted = true;
      _controller = null;
    }
    if (mounted) setState(() {});
  }

  void _retryInit() {
    setState(() {
      _initAttempted = false;
      _initTimedOut = false;
      _invalidVideoId = false;
      _controller = null;
    });
    _initController();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controllerSubscription?.cancel();
    _controller?.close();
    _isMuted.dispose();
    super.dispose();
  }

  /// Извлекает YouTube video ID из URL или возвращает строку как ID, если это уже 11 символов.
  String _extractVideoId(String url) {
    final raw = url.trim();
    if (raw.isEmpty) return '';
    debugPrint('YoutubeScreen original URL: $raw');
    // Если строка — 11 символов (формат ID), считаем её ID
    if (raw.length == 11 && RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(raw)) {
      debugPrint('YoutubeScreen using as video ID: $raw');
      return raw;
    }
    // Ищем ID в URL (v=, embed/, youtu.be/ — ищем в полном URL, не обрезая по ?)
    final regExp = RegExp(r'(?:v=|\/embed\/|youtu\.be\/)([A-Za-z0-9_-]{11})');
    final match = regExp.firstMatch(raw);
    final videoId = match?.group(1) ?? '';
    debugPrint('YoutubeScreen extracted video ID: $videoId');
    return videoId;
  }

  void _onPlayerStateChanged(YoutubePlayerValue value) {
    if (!_markedWatched && value.playerState == PlayerState.ended) {
      _markVideoAsWatched();
    }
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

  Widget _buildBackOnlyScaffold() {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.lesson.lessonTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    if (!kIsWeb) enableScreenshot();
                  },
                  child: Text(
                    'Артқа қайту',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 18,
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

  /// На веб не используем встроенный плеер — открываем видео во внешней вкладке.
  Widget _buildWebFallbackScaffold() {
    final videoUrl = widget.videoUrlOverride ?? widget.lesson.videoUrl;
    final hasUrl = videoUrl.isNotEmpty;
    final launchUri = hasUrl
        ? Uri.tryParse(videoUrl.startsWith('http') ? videoUrl : 'https://www.youtube.com/watch?v=$videoUrl')
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
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
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (hasUrl && launchUri != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        final ok = await launchUrl(
                          launchUri,
                          mode: LaunchMode.externalApplication,
                          webOnlyWindowName: '_blank',
                        );
                        if (!ok && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Сілтемені ашу мүмкін болмады: ${launchUri.toString()}')),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Қате: $e')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.play_circle_filled, size: 28),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Видеоны көру (жаңа қойындыда)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Видео сілтемесі жоқ.',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                ),
              ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Container(
                height: 150,
                width: double.infinity,
                child: ListView.separated(
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.lesson.materials.length,
                  itemBuilder: (context, index) => InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WebViewPage(
                            url: widget.lesson.materials[index].url,
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
                  ),
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: AppButton(
                text: 'Тестке өту',
                onPressed: () {
                  _markVideoAsWatched(shouldPopOnSuccess: false);
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextButton(
                onPressed: () {
                  _markVideoAsWatched();
                  Navigator.of(context).pop(true);
                },
                child: Text('Артқа қайту', style: TextStyle(color: AppColors.primaryBlue, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final isWide = MediaQuery.of(context).size.width > 600;

    if (controller == null && _navigatedToTest) {
      return _buildBackOnlyScaffold();
    }

    // Веб: не используем контроллер, показываем экран с кнопкой «Открыть видео».
    if (kIsWeb) return _buildWebFallbackScaffold();

    if (controller == null && (!_initAttempted || (!_initTimedOut && !_invalidVideoId))) {
      return const Scaffold(
        backgroundColor: Color(0xFFF6F7FB),
        body: SafeArea(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (controller == null && (_invalidVideoId || _initTimedOut)) {
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
                    Text(
                      _invalidVideoId
                          ? 'Видео недоступно'
                          : 'Видео не загрузилось',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _invalidVideoId
                          ? 'Не удалось определить ссылку на ролик. Попробуйте позже или обратитесь в поддержку.'
                          : 'Проверьте соединение и попробуйте ещё раз.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _invalidVideoId
                            ? () => Navigator.of(context).maybePop()
                            : _retryInit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Қайта көру',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                    if (kIsWeb) ...[
                      const SizedBox(height: 8),
                      Builder(
                        builder: (context) {
                          final url = widget.videoUrlOverride ?? widget.lesson.videoUrl;
                          if (url.isEmpty) return const SizedBox.shrink();
                          return TextButton.icon(
                            icon: const Icon(Icons.open_in_new, size: 18),
                            label: const Text('Видеоны жаңа қойындыда ашу'),
                            onPressed: () async {
                              final uri = Uri.tryParse(url.startsWith('http') ? url : 'https://www.youtube.com/watch?v=$url');
                              if (uri != null) {
                                try {
                                  await launchUrl(uri, mode: LaunchMode.externalApplication, webOnlyWindowName: '_blank');
                                } catch (_) {}
                              }
                            },
                          );
                        },
                      ),
                    ],
                    if (_invalidVideoId) ...[
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        child: Text(
                          'Артқа қайту',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
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
      controller: controller!,
      aspectRatio: aspectRatio,
      builder: (context, player) => Scaffold(
        backgroundColor: const Color(0xFFF6F7FB),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                margin: EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                ),
                child: AspectRatio(
                  aspectRatio: MediaQuery.of(context).size.width > 600 ? 16 / 4 : 16 / 12,
                  child: player,
                ),
              ),
              if (kIsWeb) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: const Text('Видеоны жаңа қойындыда ашу'),
                  onPressed: () async {
                    final url = widget.videoUrlOverride ?? widget.lesson.videoUrl;
                    if (url.isEmpty) return;
                    final uri = Uri.tryParse(url.startsWith('http') ? url : 'https://www.youtube.com/watch?v=$url');
                    if (uri != null) {
                      try {
                        await launchUrl(uri, mode: LaunchMode.externalApplication, webOnlyWindowName: '_blank');
                      } catch (_) {}
                    }
                  },
                ),
              ],
              SizedBox(height: 20,),
              // widget.lesson.materials.length == 0 ? SizedBox() : Row(children: [ Padding(padding: EdgeInsets.only(left: 15), child: Text("Сабақтың материалдары", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),),) ],),
              // SizedBox(height: 10,),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 15
                ),
                child: Container(
                  height: 150,
                  width: double.infinity,
                  child: ListView.separated(
                    separatorBuilder: (context, index) => SizedBox(width: 10,),
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.lesson.materials.length,
                    itemBuilder: (context, index){
                      return InkWell(
                        onTap: () async {
                          String privacyUrl = widget.lesson.materials[index].url;
                          Navigator.push(context, MaterialPageRoute(builder: (_) => WebViewPage(url: privacyUrl, isAction: false, lessonId: widget.lesson.lessonId, actionId: 0)));
                        },
                        child: MaterialsWidget(
                          title: widget.lesson.materials[index].name,
                          url:  widget.lesson.materials[index].url,
                        )
                      );
                    }
                  ),
                )
              ),
              const Spacer(),
              SizedBox(
                height: 20,
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                child: AppButton(
                text: "Тестке өту",
                onPressed: () {
                      _markVideoAsWatched(shouldPopOnSuccess: false);
                      _controllerSubscription?.cancel();
                      _controller?.close();
                      if (mounted) {
                        setState(() {
                          _controller = null;
                          _navigatedToTest = true;
                        });
                      }
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
                          if (!kIsWeb) {
                            enableScreenshot();
                          }
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
    );
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