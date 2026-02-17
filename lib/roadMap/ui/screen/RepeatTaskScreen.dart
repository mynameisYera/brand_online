import 'dart:math';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:brand_online/authorization/entity/RoadMapResponse.dart';

import '../../../general/GeneralUtil.dart';
import '../../entity/TaskEntity.dart';
import '../../service/youtube_service.dart';
import 'RoadMap.dart';
import 'TaskWidget.dart';
import 'NoTaskPage.dart';

class RepeatTaskScreen extends StatefulWidget {
  final int lessonId;
  final Lesson lesson;

  const RepeatTaskScreen({
    super.key,
    required this.lessonId, required this.lesson,
  });

  @override
  State<RepeatTaskScreen> createState() => _RepeatTaskScreenState();
}

class _RepeatTaskScreenState extends State<RepeatTaskScreen> with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;
  List<Task>? task = [];
  bool responseNull = false;
  List<Task> retryTasks = [];
  Profile? _profile;

  // ======== STAR BURST (в кнопке снизу) ========
  final GlobalKey _stackKey = GlobalKey();        // корневой Stack
  final GlobalKey _actionBtnKey = GlobalKey();    // ключ нижней кнопки в TaskWidget
  late final AnimationController _burstCtrl;
  late final Animation<double> _burst;
  final Random _rnd = Random();
  List<_Particle> _particles = [];
  Offset _burstOrigin = Offset.zero;
  bool _showBurst = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    getTasks();

    _burstCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200), // медленнее
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

  getTasks() async {
    final delay = Future.delayed(const Duration(seconds: 0));
    final responseFuture = YoutubeService().getRepeatTasks(widget.lessonId);

    final results = await Future.wait([responseFuture, delay]);
    final res = results[0];

    if (!mounted) return;

    if (res != null) {
      setState(() {
        if (res.tasks.isEmpty) {
          responseNull = true;
        }
        task = res.tasks;
        _profile = res.profile;
      });
    } else {
      if (mounted) Navigator.of(context).pop();
    }
  }

  // ======== STAR BURST LOGIC ========
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
  final _noScreenshot = NoScreenshot.instance;


    // screenshot
    // void disableScreenshot() async {
    //   bool result = await _noScreenshot.screenshotOff();
    //   debugPrint('Screenshot On: $result');
    // }

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
                                widthFactor: (_currentPage + 1) / (task!.length + retryTasks.length),
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
                      final hintShow  = index >= task!.length;

                      return TaskWidget(
                        isExamMode: false,
                        mockExamId: 0,
                        lesson: widget.lesson,
                        task: currentTask,
                        hintShow: hintShow,
                        isCash: false,
                        cashbackActive: false,
                        isRepeat: true,
                        isLast: _isLastPage,

                        // ключ к нижней кнопке
                        actionButtonKey: _actionBtnKey,

                        // запускаем «звёзды» в момент верного ответа
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
                      );
                    },
                  ),
                ),
              ],
            ),

            // ======= СЛОЙ ЗВЁЗД =======
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
                    'Бұл сабақтағы барлық жетістіктер жоғалады.',
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

// ======== helpers для звёзд ========
class _Particle {
  final double angle;
  final double radius;
  final double size;
  final double spin;
  final Color color;
  _Particle({required this.angle, required this.radius, required this.size, required this.spin, required this.color});
}
