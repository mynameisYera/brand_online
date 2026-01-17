import 'dart:math';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:brand_online/authorization/entity/RoadMapResponse.dart';

import '../../../general/GeneralUtil.dart';
import '../../entity/TaskEntity.dart';
import '../../entity/daily_entity.dart';
import 'RoadMap.dart';
import 'TaskWidget.dart';
import 'NoTaskPage.dart';
import 'ResultScreen.dart';

class DailyTestScreen extends StatefulWidget {
  final DailyEntity dailyEntity;

  const DailyTestScreen({
    super.key,
    required this.dailyEntity,
  });

  @override
  State<DailyTestScreen> createState() => _DailyTestScreenState();
}

class _DailyTestScreenState extends State<DailyTestScreen> with TickerProviderStateMixin {
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

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    setState(() {
      task = widget.dailyEntity.tasks;
      _profile = widget.dailyEntity.profile.toProfile();
      if (task == null || task!.isEmpty) {
        responseNull = true;
      }
    });

    _burstCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _burst = CurvedAnimation(parent: _burstCtrl, curve: Curves.easeOutCubic);
    _burstCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        if (mounted) setState(() => _showBurst = false);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _burstCtrl.dispose();
    super.dispose();
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

  void enableScreenshot() async {
    bool result = await _noScreenshot.screenshotOn();
    debugPrint('Screenshot OFF: $result');
  }

  bool get _isLastPage => (task?.length ?? 0) + retryTasks.length == _currentPage + 1;

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
                        onPressed: () => showLogoutConfirmationSheet(context),
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
                                widthFactor: (task != null && task!.isNotEmpty)
                                    ? (_currentPage + 1) / (task!.length + retryTasks.length)
                                    : 0.0,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: Container(color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(left: 5),
                        child: Text(
                          " x${_profile?.multiplier ?? ""}",
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: (task == null || task!.isEmpty)
                      ? ((responseNull == false)
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
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final currentTask = index < task!.length
                          ? task![index]
                          : retryTasks[index - task!.length];
                      final hintShow = index >= task!.length;

                      final lesson = Lesson(
                        lessonId: widget.dailyEntity.session.gradeId,
                        lessonTitle: widget.dailyEntity.session.subjectName,
                        lessonNumber: 0,
                        videoUrl: currentTask.videoSolutionUrl ?? "",
                        videoWatched: true,
                        group1Completed: true,
                        group2Completed: true,
                        group3Completed: true,
                        cashbackActive: false,
                        isPublished: true,
                        materials: [],
                      );

                      return TaskWidget(
                        lesson: lesson,
                        task: currentTask,
                        hintShow: hintShow,
                        isCash: false,
                        cashbackActive: false,
                        isRepeat: true,
                        isLast: _isLastPage,
                        dailySubjectMode: true,
                        actionButtonKey: _actionBtnKey,

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
                            retryTasks.add(incorrectTask);
                          });
                        },
                        profile: _profile,
                        
                        customShowResultScreen: (
                          int serverScore,
                          int serverPercentage,
                          int strike,
                          int temporaryBalance,
                          double factory,
                          int money,
                          bool isCash,
                          int taskCashback,
                          int totalCashback,
                        ) async {
                          await _showResultScreen(
                            serverScore,
                            serverPercentage,
                            strike,
                            temporaryBalance,
                            factory,
                            money,
                            isCash,
                            taskCashback,
                            totalCashback,
                          );
                        },
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

  Future<void> _showResultScreen(
    int score,
    int percentage,
    int strike,
    int temporaryBalance,
    double factory,
    int money,
    bool isCash,
    int taskCashback,
    int totalCashback,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ResultScreen(
        score: score,
        percentage: percentage,
        strike: strike,
        temporaryBalance: temporaryBalance,
        factory: factory,
        money: money,
        isCash: isCash,
        cashbackActive: false,
        taskCashback: taskCashback,
        totalCashback: totalCashback,
      ),
    );
    if (!mounted) return;

    enableScreenshot();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => RoadMap(selectedIndx: 1, state: 0),
      ),
      (Route<dynamic> route) => false,
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Сіз сенімдісіз бе?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),
              Center(
                child: SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.7,
                  child: const Text(
                    'Бұл тесттегі барлық жетістіктер жоғалады.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: GeneralUtil.orangeColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'ЖАЛҒАСТЫРУ',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () { 
                  enableScreenshot();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RoadMap(selectedIndx: 1, state: 0),
                    ),
                        (Route<dynamic> route) => false,
                  );
                },
                child: const Text(
                  'ШЫҒУ',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 30),
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
