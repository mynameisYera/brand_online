import 'dart:math';
import 'package:brand_online/core/widgets/app_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:brand_online/authorization/entity/RoadMapResponse.dart';
import 'package:brand_online/general/GeneralUtil.dart';
import 'package:brand_online/roadMap/entity/ControlExam.dart';
import 'package:brand_online/roadMap/entity/TaskEntity.dart';
import 'package:brand_online/roadMap/service/task_service.dart';
import 'package:brand_online/roadMap/ui/screen/ResultScreen.dart';
import 'package:brand_online/roadMap/ui/screen/RoadMap.dart';
import 'package:brand_online/roadMap/ui/screen/TaskWidget.dart';

class MockExamScreen extends StatefulWidget {
  final MockExam exam;

  const MockExamScreen({super.key, required this.exam});

  @override
  State<MockExamScreen> createState() => _MockExamScreenState();
}

class _MockExamScreenState extends State<MockExamScreen>
    with TickerProviderStateMixin {
  final TaskService _taskService = TaskService();

  bool _loading = true;
  String? _error;

  late PageController _pageController;
  int _currentPage = 0;
  List<Task> _tasks = [];
  List<Task> _retryTasks = [];
  int _correctCount = 0;
  Profile? _profile;

  final GlobalKey _actionBtnKey = GlobalKey();
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
    _profile = Profile(
      id: 0,
      role: 0,
      grade: widget.exam.gradeId,
      strike: 0,
      points: 0,
      multiplier: '1',
    );
    _burstCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _burst = CurvedAnimation(parent: _burstCtrl, curve: Curves.easeOutCubic);
    _burstCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) {
        setState(() => _showBurst = false);
      }
    });
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _taskService.getMockExamTasks(widget.exam.id);
      if (!mounted) return;
      if (result == null) {
        setState(() {
          _loading = false;
          _error = 'Тапсырмалар жүктелмеді';
        });
        return;
      }
      setState(() {
        _tasks = result.tasks;
        _loading = false;
        _error = result.tasks.isEmpty ? 'Тапсырмалар жоқ' : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Қате: $e';
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _burstCtrl.dispose();
    super.dispose();
  }

  bool get _isLastPage =>
      (_tasks.length + _retryTasks.length) == _currentPage + 1;

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
      return _Particle(
          angle: angle, radius: radius, size: size, spin: spin, color: color);
    });
  }

  Future<void> _playButtonBurst() async {
    final stackBox = _actionBtnKey.currentContext?.findRenderObject() as RenderBox?;
    if (stackBox == null) return;
    final btnTopLeft = stackBox.localToGlobal(Offset.zero);
    _prepareParticles();
    setState(() {
      _burstOrigin = btnTopLeft + Offset(stackBox.size.width / 2, stackBox.size.height / 2);
      _showBurst = true;
    });
    _burstCtrl.forward(from: 0);
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
    // API часто возвращает percentage: 0.0 для сынақа — считаем % по правильным ответам
    final totalCount = _tasks.length + _retryTasks.length;
    final displayPercentage = totalCount > 0
        ? (_correctCount / totalCount * 100).round().clamp(0, 100)
        : percentage;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ResultScreen(
        score: score,
        percentage: displayPercentage,
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
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => RoadMap(selectedIndx: 2, state: 0),
      ),
      (Route<dynamic> route) => false,
    );
  }

  void _exitConfirm() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Сынақтан шығасыз ба?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Жалғастыру',
                    onPressed: () => Navigator.pop(ctx),
                    // child: const Text('Жалғастыру'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    color: AppButtonColor.red,
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) =>
                              RoadMap(selectedIndx: 2, state: 0),
                        ),
                        (route) => false,
                      );
                    },
                    text: 'Шығу',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: LoadingAnimationWidget.progressiveDots(
            color: GeneralUtil.mainColor,
            size: 48,
          ),
        ),
      );
    }

    if (_error != null || _tasks.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(widget.exam.title),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _error ?? 'Тапсырмалар жоқ',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Артқа'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final totalCount = _tasks.length + _retryTasks.length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
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
                        onPressed: _exitConfirm,
                      ),
                      Expanded(
                        child: Container(
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
                                widthFactor: (_currentPage + 1) / totalCount,
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
                          ' x${_profile?.multiplier ?? "1"}',
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
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: totalCount,
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    itemBuilder: (context, index) {
                      final currentTask = index < _tasks.length
                          ? _tasks[index]
                          : _retryTasks[index - _tasks.length];
                      final hintShow = index >= _tasks.length;

                      final lesson = Lesson(
                        lessonId: currentTask.lessonId,
                        lessonTitle: widget.exam.title,
                        lessonNumber: 0,
                        videoUrl: currentTask.videoSolutionUrl ?? '',
                        videoWatched: true,
                        group1Completed: true,
                        group2Completed: true,
                        group3Completed: true,
                        cashbackActive: false,
                        isPublished: true,
                        materials: [],
                      );

                      return TaskWidget(
                        key: ValueKey(currentTask.id),
                        lesson: lesson,
                        task: currentTask,
                        hintShow: hintShow,
                        isCash: false,
                        cashbackActive: false,
                        isRepeat: true,
                        isLast: _isLastPage,
                        dailySubjectMode: false,
                        actionButtonKey: _actionBtnKey,
                        onCorrect: () async {
                          setState(() => _correctCount++);
                          await _playButtonBurst();
                        },
                        onNext: () {
                          if (_currentPage + 1 < totalCount) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        onAnswerIncorrect: (Task incorrectTask) {
                          setState(() => _retryTasks.add(incorrectTask));
                        },
                        profile: _profile,
                        customShowResultScreen: (score, percentage, strike, temporaryBalance, factory, money, isCash, taskCashback, totalCashback) => _showResultScreen(score, percentage, strike, temporaryBalance, factory, money, isCash, taskCashback, totalCashback),
                      );
                    },
                  ),
                ),
              ],
            ),
            if (_showBurst)
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _burst,
                    builder: (context, _) {
                      final t = _burst.value;
                      final eased = Curves.easeOutBack.transform(t);
                      return Stack(
                        children: [
                          for (final p in _particles)
                            Positioned(
                              left: _burstOrigin.dx +
                                  cos(p.angle) * p.radius * eased -
                                  p.size / 2,
                              top: _burstOrigin.dy +
                                  sin(p.angle) * p.radius * eased -
                                  p.size / 2,
                              child: Transform.rotate(
                                angle: p.spin * t,
                                child: Opacity(
                                  opacity: (1.0 - t).clamp(0.0, 1.0),
                                  child: Transform.scale(
                                    scale: 0.8 + 0.6 * (1 - t),
                                    child: Icon(Icons.star_rounded,
                                        size: p.size, color: p.color),
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
}

class _Particle {
  final double angle;
  final double radius;
  final double size;
  final double spin;
  final Color color;
  _Particle({
    required this.angle,
    required this.radius,
    required this.size,
    required this.spin,
    required this.color,
  });
}
