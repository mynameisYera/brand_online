import 'dart:math';
import 'package:brand_online/core/app_colors.dart';
import 'package:brand_online/core/text_styles.dart';
import 'package:brand_online/core/widgets/app_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:brand_online/authorization/entity/RoadMapResponse.dart';
import 'package:brand_online/roadMap/ui/widget/JustAudioBar.dart';

import '../../../general/GeneralUtil.dart';
import '../../../utils/screen_secure.dart';
import '../../entity/TaskEntity.dart';
import '../../service/youtube_service.dart';
import '../../entity/ProfileController.dart';
import 'RoadMap.dart';
import 'TaskWidget.dart';
import 'NoTaskPage.dart';

class Math1Screen extends StatefulWidget {
  final int lessonId;
  final int groupId;
  final double initialScrollOffset;
  final bool isCash;
  final bool cashbackActive;
  final bool dailyReview;
  final Lesson lesson;

  const Math1Screen({
    super.key,
    this.initialScrollOffset = 0.0,
    required this.lessonId,
    required this.groupId,
    required this.isCash,
    required this.cashbackActive,
    this.dailyReview = false, 
    required this.lesson,
  });

  @override
  State<Math1Screen> createState() => _Math1ScreenState();
}

class _Math1ScreenState extends State<Math1Screen> with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;
  List<Task>? task = [];
  bool responseNull = false;
  List<Task> retryTasks = [];
  Profile? _profile;

  final GlobalKey _stackKey = GlobalKey();
  final GlobalKey _actionBtnKey = GlobalKey();
  late final AnimationController _burstCtrl;
  late final Animation<double> _burst;
  final Random _rnd = Random();
  List<_Particle> _particles = [];
  Offset _burstOrigin = Offset.zero;
  bool _showBurst = false;
  final _noScreenshot = NoScreenshot.instance;


    // screenshot
    // void disableScreenshot() async {
    //   bool result = await _noScreenshot.screenshotOff();
    //   debugPrint('Screenshot Off: $result');
    // }

    void enableScreenshot() async {
      bool result = await _noScreenshot.screenshotOn();
      debugPrint('Enable Screenshot: $result');
    }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initWithSplashDelay();

    ScreenSecure.enable();

    _burstCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _burst = CurvedAnimation(parent: _burstCtrl, curve: Curves.easeOutCubic);
    _burstCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        setState(() => _showBurst = false);
      }
    });
  }

  @override
  void dispose() {
    ScreenSecure.disable();
    _pageController.dispose();
    _burstCtrl.dispose();
    super.dispose();
  }

  Future<void> _initWithSplashDelay() async {
    final tasksFuture = widget.dailyReview
        ? YoutubeService().getDailyReviewTasks()
        : (widget.isCash
        ? YoutubeService().getCashTasks()
        : YoutubeService().getTasks(widget.lessonId, widget.groupId));

    final delay = Future.delayed(const Duration(seconds: 0));
    final results = await Future.wait([tasksFuture, delay]);
    final res = results[0];

    if (res != null) {
      setState(() {
        if (res.tasks.isEmpty) responseNull = true;
        task = res.tasks;
        _profile = res.profile;
      });
    } else {
      if (mounted) Navigator.of(context).pop();
    }
  }

  Task? _taskByIndex(int index) {
    if (task == null) return null;
    if (index < task!.length) return task![index];
    final retryIndex = index - task!.length;
    if (retryIndex >= 0 && retryIndex < retryTasks.length) {
      return retryTasks[retryIndex];
    }
    return null;
  }

  String? get _currentAudioUrl {
    final t = _taskByIndex(_currentPage);
    final url = t?.audioUrl;
    if (url == null || url.trim().isEmpty) return null;
    return url;
  }

  getTasks() async {
    YoutubeService().getTasks(widget.lessonId, widget.groupId).then((res) {
      if (res != null) {
        setState(() {
          if (res.tasks.isEmpty) {
            responseNull = true;
          }
          task = res.tasks;
          _profile = res.profile;
        });
      } else {
        Navigator.of(context).pop();
      }
    });
  }

  void _prepareParticles({int count = 18, double maxRadius = 110}) {
    _particles = List.generate(count, (i) {
      final angle = _rnd.nextDouble() * 2 * pi;
      final radius = maxRadius * (0.6 + _rnd.nextDouble() * 0.4);
      final size = 9 + (_rnd.nextDouble() * 11);
      final spin = (_rnd.nextBool() ? 1 : -1) * (_rnd.nextDouble() * pi);
      final color = [
        Colors.amber,
        Colors.orangeAccent,
        Colors.yellow,
        Colors.white
      ][_rnd.nextInt(4)];
      return _Particle(angle: angle, radius: radius, size: size, spin: spin, color: color);
    });
  }

  Future<void> _playButtonBurst() async {
    final stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    final btnBox = _actionBtnKey.currentContext?.findRenderObject() as RenderBox?;
    if (stackBox == null || btnBox == null) return;

    final btnTopLeft = btnBox.localToGlobal(Offset.zero);
    final btnCenter = btnTopLeft + Offset(btnBox.size.width / 2, btnBox.size.height / 2);

    final stackTopLeft = stackBox.localToGlobal(Offset.zero);
    final local = btnCenter - stackTopLeft;

    _prepareParticles();
    setState(() {
      _burstOrigin = local;
      _showBurst = true;
    });
    _burstCtrl.forward(from: 0);
  }

  bool get _isLastPageCashAware {
    if (task == null) return false;
    return widget.isCash
        ? (task!.length == _currentPage + 1)
        : (task!.length + retryTasks.length == _currentPage + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          key: _stackKey,
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () async => showLogoutConfirmationSheet(context),
                      ),
                      Flexible(
                        child: Container(
                          alignment: Alignment.topLeft,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: (task!.length == 0)
                                    ? 0
                                    : (_currentPage + 1) / (task!.length + retryTasks.length),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: Container(
                                    color: widget.isCash ? Colors.amber : Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(left: 5),
                        child: ValueListenableBuilder<String>(
                          valueListenable: ProfileController.multiplierNotifier,
                          builder: (context, multiplier, _) {
                            return Text(
                              "x$multiplier",
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 20,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.none,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                if (_currentAudioUrl != null) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
                    child: Image.asset('assets/images/admbrs6.png', fit: BoxFit.contain, height: 70),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
                    child: JustAudioBar(url: _currentAudioUrl!, accent: GeneralUtil.mainColor),
                  ),
                ],

                Expanded(
                  child: (task == null || task!.isEmpty)
                      ? (responseNull == false
                      ? Scaffold(
                    backgroundColor: Colors.white,
                    body: SizedBox.expand(
                      child: Center(
                        child: LoadingAnimationWidget.progressiveDots(
                          color: GeneralUtil.mainColor,
                          size: MediaQuery.of(context).size.width * 0.2,
                        ),
                      ),
                    ),
                  )
                      : const NoTasksPage())
                      : PageView.builder(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: (task!.length + retryTasks.length),
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    itemBuilder: (context, index) {
                      final currentTask = index < task!.length
                          ? task![index]
                          : retryTasks[index - task!.length];
                      final hintShow = index >= task!.length;

                      return TaskWidget(
                        isExamMode: false,
                        mockExamId: 0,
                        task: currentTask,
                        isRepeat: false,
                        cashbackActive: widget.cashbackActive,
                        isCash: widget.isCash,
                        hintShow: hintShow,
                        dailyReview: widget.dailyReview,
                        isLast: _isLastPageCashAware,
                        actionButtonKey: _actionBtnKey,
                        lesson: widget.lesson,
                        onCorrect: () async {
                          await _playButtonBurst();
                        },

                        onNext: () {
                          if (_currentPage + 1 < (task!.length + retryTasks.length)) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },


                        onAnswerIncorrect: (Task incorrectTask) {
                          setState(() {
                            if (widget.isCash == false) {
                              retryTasks.add(incorrectTask);
                            }
                          });
                        },
                        profile: _profile,
                      );
                    },
                  ),
                ),
              ],
            ),

            if (_showBurst)
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: true,
                  child: AnimatedBuilder(
                    animation: _burst,
                    builder: (context, _) {
                      final t = _burst.value;
                      final eased = Curves.easeOutBack.transform(t);
                      return Stack(
                        children: [
                          for (final p in _particles)
                            Positioned(
                              left: _burstOrigin.dx + cos(p.angle) * p.radius * eased - p.size / 2,
                              top:  _burstOrigin.dy + sin(p.angle) * p.radius * eased - p.size / 2,
                              child: Transform.rotate(
                                angle: p.spin * t,
                                child: Opacity(
                                  opacity: (1.0 - t).clamp(0.0, 1.0),
                                  child: Transform.scale(
                                    scale: 0.8 + 0.6 * (1 - t),
                                    child: Icon(Icons.star_rounded, size: p.size, color: p.color),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void showLogoutConfirmationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                height: 8,
                width: 60,
                decoration: BoxDecoration(
                  color: AppColors.grey,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'Сіз сенімдісіз бе?',
                style: TextStyles.semibold(AppColors.black, fontSize: 20),
              ),
              const SizedBox(height: 15),
              Center(
                child: SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.7,
                  child: Text(
                    'Бұл сабақтағы барлық жетістіктер жоғалады.',
                    textAlign: TextAlign.center,
                    style: TextStyles.bold(AppColors.errorRed, fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                text: 'ЖАЛҒАСТЫРУ', 
                onPressed: () async {
                  Navigator.of(context).pop();
                }
              ),
              
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () { Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RoadMap(
                      initialScrollOffset: widget.initialScrollOffset,
                      selectedIndx: (widget.dailyReview || widget.isCash) ? 1 : 0,
                      state: 0,
                    ),
                  ),
                      (Route<dynamic> route) => false,
                );
                enableScreenshot();
                },
                child: const Text('ШЫҒУ', style: TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}

class _Particle {
  final double angle;
  final double radius;
  final double size;
  final double spin;
  final Color color;
  _Particle({required this.angle, required this.radius, required this.size, required this.spin, required this.color});
}
