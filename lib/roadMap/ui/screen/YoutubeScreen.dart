import 'package:brand_online/core/app_colors.dart';
import 'package:brand_online/core/text_styles.dart';
import 'package:brand_online/core/widgets/app_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:brand_online/roadMap/ui/screen/Math1Screen.dart';
import 'package:brand_online/roadMap/ui/screen/web_view_page.dart';
import 'package:brand_online/roadMap/ui/widget/materials_widget.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
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
  bool _markedWatched = false;
  final _noScreenshot = NoScreenshot.instance;
  static const List<double> _playbackRates = [1.0, 1.25, 1.5, 1.75, 2.0];

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

  _controller = YoutubePlayerController(
    initialVideoId: videoId,
    flags: const YoutubePlayerFlags(
      autoPlay: true,
      mute: false,
      loop: false,
      disableDragSeek: false,
      enableCaption: false,
      hideThumbnail: true,
    ),
  )..addListener(_onPlayerStateChanged);
}

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  _controller?.removeListener(_onPlayerStateChanged);
  _controller?.dispose();
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

  void _onPlayerStateChanged() {
    final controller = _controller;
    if (controller == null) return;
    if (!_markedWatched && controller.value.playerState == PlayerState.ended) {
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

  return YoutubePlayerBuilder(
    player: YoutubePlayer(
      controller: controller,
      thumbnail: Container(
        color: Color(0xff0082ff),
        child: Image.asset("assets/images/mainLogo.png"),
      ),
      showVideoProgressIndicator: true,
      progressIndicatorColor: Colors.blue,
      bottomActions: [
        const SizedBox(width: 8),
        CurrentPosition(),
        const SizedBox(width: 10),
        ProgressBar(
          isExpanded: true,
          // controller: controller,
          colors: const ProgressBarColors(
            playedColor: Colors.blueAccent,
            handleColor: Colors.blue,
            bufferedColor: Color(0xFF90CAF9),
            backgroundColor: Color(0xFFE3F2FD),
          ),
        ),
        
        const SizedBox(width: 10),
        RemainingDuration(),
        const SizedBox(width: 10),
        _buildPlaybackSpeedButton(controller),
        const SizedBox(width: 10),
        FullScreenButton(),
      ],
    ),
    builder: (context, player) => Scaffold(
        backgroundColor: Colors.white,
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
                          Navigator.push(context, MaterialPageRoute(builder: (_) => WebViewPage(url: privacyUrl,)));
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
                      _controller?.removeListener(_onPlayerStateChanged);
                      _controller?.dispose();
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
                    },),
              ),
              SizedBox(height: 10,),
              Center(
                child: TextButton(
                  onPressed: () {
                      _markVideoAsWatched();
                      Navigator.of(context).pop(true);
                      enableScreenshot();
                    },
                  child: Text("Артқа қайту", style: TextStyles.medium(AppColors.primaryBlue),)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaybackSpeedButton(YoutubePlayerController controller) {
    return ValueListenableBuilder<YoutubePlayerValue>(
      valueListenable: controller,
      builder: (context, value, child) {
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
}