// ignore_for_file: unused_element

import 'package:brand_online/core/app_colors.dart';
import 'package:brand_online/core/text_styles.dart';
import 'package:brand_online/roadMap/ui/widget/repeat_cart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:brand_online/authorization/entity/RoadMapResponse.dart';
import 'package:brand_online/roadMap/entity/daily_entity.dart';
import 'package:brand_online/roadMap/ui/screen/NoTaskPage.dart';
import 'package:brand_online/roadMap/ui/screen/YoutubeUrlScreen.dart';
import '../../../general/GeneralUtil.dart';
import '../../entity/ControlExam.dart';
import '../../entity/DailyReview.dart';
import '../../entity/ProfileController.dart';
import 'CustomAppBar.dart';
import 'Math1Screen.dart';
import '../../service/task_service.dart';
import '../../entity/RestartLesson.dart';
import 'RepeatTaskScreen.dart';
import 'zhdt_test.dart' show DailyTestScreen;
import 'package:brand_online/synaq/page/mock_exam_screen.dart';

class RepeatPage extends StatefulWidget {
  const RepeatPage({super.key});

  @override
  State<RepeatPage> createState() => _RepeatPageState();
}

class _RepeatPageState extends State<RepeatPage> {
  final TaskService _taskService = TaskService();

  List<RestartLesson> lessons = [];
  ControlExam? controlExam;
  DailyReview? dailyReview;
  List<DailySession>? dailySubjectTasks;
  MockExam? mockExam;

  bool responseNull = false;
  bool controlExamStarted = false;
  bool _loading = true;
  bool _hasAny = false;
  int? expandedIndex;
  bool _dailyTasksExpanded = false;

  final List<Color> colors = const [
    Color(0xFF4BA7FF),
    Color(0xFF8DDF54),
    Color(0xFFD39DFF),
    Color(0xFFFFD942),
    Color(0xFFFF8255),
  ];

  @override
  void initState() {
    fetchLessons();
    super.initState();
  }


  Future<void> fetchLessons() async {
    try {
      final result = await _taskService.getRestartLessons();
      if (!mounted) return;

      final ls   = result?.lessons ?? [];
      final exam = result?.controlExam;
      final dr   = result?.dailyReview;
      dailySubjectTasks = result?.dailySubjectTasks;
      final mock = result?.mockExam;

      // Проверяем активные daily subject tasks
      final hasActiveDailySessions = dailySubjectTasks != null && 
          dailySubjectTasks!.isNotEmpty &&
          dailySubjectTasks!.any((session) => 
            !session.isCompleted && 
            (session.remainingTasks > 0 || session.completedTasks > 0)
          );
      
      // Проверяем активный daily review (открыт и не завершен)
      final hasActiveDailyReview = dr?.isOpen == true && dr?.isCompleted == false;
      
      final hasMockExam = mock != null && !mock.attempt.isCompleted;
      int count = 0;
      if (hasMockExam) count++;
      if (hasActiveDailyReview) {
        count++;
      }
      if (hasActiveDailySessions) {
        count++;
      }
      // Repeat lessons
      if (ls.isNotEmpty) {
        count++;
      }
      // Control exam
      if (exam?.isOpen == true) {
        count++;
      }
      
      // Update the counter
      ProfileController.setRepeatCount(count);

      setState(() {
        lessons     = ls;
        controlExam = exam;
        dailyReview = dr;
        mockExam    = mock;
        // _hasAny должен быть true если есть хотя бы один активный элемент
        _hasAny = hasMockExam ||
                  ls.isNotEmpty || 
                  (exam?.isOpen ?? false) || 
                  hasActiveDailyReview || 
                  hasActiveDailySessions;
        _loading = false;
        responseNull = result == null;
      });
    } catch (e) {
      if (!mounted) return;
      // Reset count on error
      ProfileController.setRepeatCount(0);
      setState(() {
        lessons = [];
        controlExam = null;
        dailyReview = null;
        mockExam = null;
        _hasAny = false;
        _loading = false;
        responseNull = true;
      });
    }
  }

  void _onMockExamStart() async {
    if (mockExam == null) return;
    if (mockExam!.attempt.isCompleted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MockExamScreen(exam: mockExam!),
      ),
    );
    if (!mounted) return;
    fetchLessons();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: Colors.blue,)),
      );
    }

    if (!_hasAny) {
      return const NoTasksPage();
    }

    final hasActiveDailySessions = dailySubjectTasks != null && 
        dailySubjectTasks!.isNotEmpty &&
        dailySubjectTasks!.any((session) => 
          !session.isCompleted && 
          (session.remainingTasks > 0 || session.completedTasks > 0)
        );
    final body = RefreshIndicator(
      color: GeneralUtil.blueColor,
      onRefresh: fetchLessons,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  CustomAppBar(),
                  const SizedBox(height: 16),
                  if (mockExam != null) _MockExamCard(mockExam: mockExam!, onStart: _onMockExamStart),
                  if (mockExam != null) const SizedBox(height: 16),
                  if (controlExam?.isOpen ?? false) RepeatCart(
                    subject: "Кэшбекті еселендір!", 
                    title: "Апталық қорытынды тест", 
                    mascotAsset: "assets/images/SHOQAN.png", 
                    iconAsset: "assets/icons/qortyndy.svg",
                    onStart: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Math1Screen(
                              initialScrollOffset: 0,
                              lessonId: 0,
                              cashbackActive: false,
                              groupId: 0,
                              isCash: true,
                              lesson: Lesson(lessonId: 0, lessonTitle: "lll", lessonNumber: 0, videoUrl: "lll", videoWatched: true, group1Completed: true, group2Completed: true, group3Completed: true, cashbackActive: false, isPublished: true, materials: [],)
                            ),
                          ),
                        );
                      },
                    isCompleted: false,
                    color: AppColors.trueGreen,
                  ),
                  SizedBox(height: 16),
                  if (dailyReview?.isOpen == true && dailyReview?.isCompleted == false) RepeatCart(
                    subject: "Өзіңді сынап көр!", 
                    subtitle: dailyReview!.subjectName,
                    title: "Күнделікті қайталау ", 
                    mascotAsset: "assets/images/ABAI.png", 
                    iconAsset: "assets/icons/repeat.svg",
                    onStart: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => Math1Screen(
                                lesson: Lesson(lessonId: 0, lessonTitle: "lll", lessonNumber: 0, videoUrl: "lll", videoWatched: true, group1Completed: true, group2Completed: true, group3Completed: true, cashbackActive: false, isPublished: true, materials: []),
                                initialScrollOffset: 0,
                                lessonId: 0,
                                cashbackActive: false,
                                dailyReview: true,
                                groupId: 0,
                                isCash: false,
                              ),
                            ),
                          );
                          if (!mounted) return;
                          fetchLessons();
                        },
                    isCompleted: false,
                    color: AppColors.yellow,
                  ),
                  
                  const SizedBox(height: 12),
                  // if (controlExam?.isOpen ?? false)
                  //   _ControlExamCard(
                  //     controlExam: controlExam!,
                  //     started: controlExamStarted,
                  //     onTap: () {
                  //       setState(() {
                  //         controlExamStarted = true;
                  //       });
                  //     },
                  //     onStart: () async {
                  //       await Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //           builder: (context) => Math1Screen(
                  //             initialScrollOffset: 0,
                  //             lessonId: 0,
                  //             cashbackActive: false,
                  //             groupId: 0,
                  //             isCash: true,
                  //             lesson: Lesson(lessonId: 0, lessonTitle: "lll", lessonNumber: 0, videoUrl: "lll", videoWatched: true, group1Completed: true, group2Completed: true, group3Completed: true, cashbackActive: false, isPublished: true, materials: [],)
                  //           ),
                  //         ),
                  //       );
                  //     },
                  //   ),
                  // if (dailyReview?.isOpen == true && dailyReview?.isCompleted == false)
                  //   Padding(
                  //     padding: const EdgeInsets.only(bottom: 16),
                  //     child: DailyReviewTile(
                  //       subject: dailyReview!.subjectName,
                  //       isCompleted: dailyReview!.isCompleted,
                  //       onStart: () async {
                  //         await Navigator.push(
                  //           context,
                  //           MaterialPageRoute(
                  //             builder: (_) => Math1Screen(
                  //               lesson: Lesson(lessonId: 0, lessonTitle: "lll", lessonNumber: 0, videoUrl: "lll", videoWatched: true, group1Completed: true, group2Completed: true, group3Completed: true, cashbackActive: false, isPublished: true, materials: []),
                  //               initialScrollOffset: 0,
                  //               lessonId: 0,
                  //               cashbackActive: false,
                  //               dailyReview: true,
                  //               groupId: 0,
                  //               isCash: false,
                  //             ),
                  //           ),
                  //         );
                  //         if (!mounted) return;
                  //         fetchLessons();
                  //       },
                  //     ),
                  //   ),
                  if (hasActiveDailySessions)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _ExpandableDailyTasksSection(
                        dailyTasks: dailySubjectTasks!,
                        isExpanded: _dailyTasksExpanded,
                        onToggle: () {
                          setState(() {
                            _dailyTasksExpanded = !_dailyTasksExpanded;
                          });
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
          // if (lessons.isEmpty)
          //   SliverToBoxAdapter(
          //     child: Padding(
          //       padding: const EdgeInsets.only(top: 48),
          //       child: Center(
          //         child: Text(
          //           responseNull
          //               ? "Қазір тапсырмалар қолжетімді емес"
          //               : "Қайталайтын сабақтар табылмады",
          //           style: theme.textTheme.bodyLarge
          //               ?.copyWith(color: Colors.grey[600]),
          //         ),
          //       ),
          //     ),
          //   ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final lesson = lessons[index];
                  final color = colors[index % colors.length];
                  final expanded = expandedIndex == index;
                  return _LessonCard(
                    lesson: lesson,
                    color: color,
                    expanded: expanded,
                    onToggle: () {
                      setState(() {
                        expandedIndex = expanded ? null : index;
                      });
                    },
                  );
                },
                childCount: lessons.length,
              ),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(child: body),
    );
  }
}

class _MockExamCard extends StatelessWidget {
  const _MockExamCard({
    required this.mockExam,
    required this.onStart,
  });

  final MockExam mockExam;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final attempt = mockExam.attempt;
    final isCompleted = attempt.isCompleted;
    final subtitle = attempt.answeredCount > 0
        ? '${attempt.answeredCount}/${mockExam.taskCount} сұрақ · ${attempt.percentage.toStringAsFixed(0)}%'
        : '${mockExam.taskCount} сұрақ';

    return RepeatCart(
      subject: '${mockExam.gradeName} · ${mockExam.subjectName}',
      title: mockExam.title,
      subtitle: subtitle,
      mascotAsset: 'assets/images/SHOQAN.png',
      iconAsset: 'assets/icons/qortyndy.svg',
      onStart: onStart,
      isCompleted: isCompleted,
      color: AppColors.trueGreen,
    );
  }
}

class _ControlExamCard extends StatelessWidget {
  const _ControlExamCard({
    required this.controlExam,
    required this.started,
    required this.onTap,
    required this.onStart,
  });

  final ControlExam controlExam;
  final bool started;
  final VoidCallback onTap;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 150,
          decoration: BoxDecoration(
            color: const Color(0xFF4BA7FF),
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Stack(
            children: [
              Positioned(
                right: 2,
                bottom: 0,
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: Image.asset(
                    "assets/images/admbrs12.png",
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 20,),
                  Row(
                    children: const [
                      Icon(Icons.menu_book, color: Colors.white),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Апталық қорытынды тест",
                          maxLines: 2,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Кэшбек еселендір!",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  started
                      ? OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: GeneralUtil.blueColor,
                            side: const BorderSide(color: Colors.white),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: onStart,
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("Кеттік!"),
                              SizedBox(width: 6),
                              Icon(Icons.arrow_forward),
                            ],
                          ),
                        )
                      : Text(
                          controlExam.date ?? '',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({
    required this.lesson,
    required this.color,
    required this.expanded,
    required this.onToggle,
  });

  final RestartLesson lesson;
  final Color color;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: color.withOpacity(0.9),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Тарау ${lesson.chapterId}",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    lesson.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "${lesson.overallPercentage.toInt()}%",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: expanded
                        ? Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => RepeatTaskScreen(
                                            lessonId: lesson.lessonId,
                                            lesson: Lesson(lessonId: 0, lessonTitle: "lll", lessonNumber: 0, videoUrl: "lll", videoWatched: true, group1Completed: true, group2Completed: true, group3Completed: true, cashbackActive: false, isPublished: true, materials: [],)
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: color,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: const Text("Тапсырма"),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => YoutubeUrlScreen(
                                            videoSolutionUrl: lesson.videoUrl,
                                            lesson: Lesson(lessonId: lesson.lessonId, lessonTitle: lesson.title, lessonNumber: lesson.chapterId, videoUrl: lesson.videoUrl, videoWatched: true, group1Completed: true, group2Completed: true, group3Completed: true, cashbackActive: false, isPublished: false, materials: lesson.materials),
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.play_circle_fill),
                                    label: const Text("Видео сабақ"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: color,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DailyTaskCard extends StatelessWidget {
  const _DailyTaskCard({
    required this.dailyEntity,
    required this.onTap,
  });

  final DailyEntity dailyEntity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final session = dailyEntity.session;
    final progress = session.targetCount > 0 
        ? (session.questionsCompleted / session.targetCount).clamp(0.0, 1.0)
        : 0.0;
    final isCompleted = session.isCompleted;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: isCompleted ? null : onTap,
        child: Opacity(
          opacity: isCompleted ? 0.7 : 1.0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isCompleted
                    ? [
                        const Color(0xFF8DDF54),
                        const Color(0xFF6BCB3D),
                      ]
                    : [
                        const Color(0xFF4BA7FF),
                        const Color(0xFF3A8FE6),
                      ],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: (isCompleted ? const Color(0xFF8DDF54) : const Color(0xFF4BA7FF))
                      .withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: isCompleted ? null : onTap,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isCompleted ? Icons.check_circle : Icons.quiz,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                session.subjectName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                session.gradeName,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check,
                                  color: Color(0xFF6BCB3D),
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "Аяқталды",
                                  style: TextStyle(
                                    color: Color(0xFF6BCB3D),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Прогресс",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "${session.questionsCompleted}/${session.targetCount}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _StatItem(
                            icon: Icons.assignment,
                            label: "Тапсырмалар",
                            value: "${session.remainingTasks} қалды",
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatItem(
                            icon: Icons.stars,
                            label: "Ұпайлар",
                            value: "${session.points}",
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    if (session.correctFirstTry > 0) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.verified,
                            color: Colors.white.withOpacity(0.9),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "${session.correctFirstTry} дұрыс жауап",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ));
  }
}

class _ExpandableDailyTasksSection extends StatelessWidget {
  const _ExpandableDailyTasksSection({
    required this.dailyTasks,
    required this.isExpanded,
    required this.onToggle,
  });

  final List<DailySession> dailyTasks;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.fiolet,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(8),
                topRight: const Radius.circular(8),
                bottomLeft: isExpanded ? Radius.zero : const Radius.circular(8),
                bottomRight: isExpanded ? Radius.zero : const Radius.circular(8),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(8),
                  topRight: const Radius.circular(8),
                  bottomLeft: isExpanded ? Radius.zero : const Radius.circular(8),
                  bottomRight: isExpanded ? Radius.zero : const Radius.circular(8),
                ),
                onTap: onToggle,
                child: Stack(
                  children: [
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Image.asset(
                        "assets/images/MYRZHAKYP.png",
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.all(7),
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: SvgPicture.asset(
                                "assets/icons/upup.svg",
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Жеке даму траекториясы",
                                  style: TextStyles.semibold(
                                    AppColors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const SizedBox(width: 16),
                            Text(
                              "Өзіңді сынап көр!",
                              style: TextStyles.semibold(
                                AppColors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        
                        
                        const SizedBox(height: 16),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: isExpanded
              ? Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.fiolet,
                        AppColors.fiolet,
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                    ),
                  ),
                  child: Column(
                    children: [
                      ...dailyTasks.asMap().entries.map((entry) {
                        final index = entry.key;
                        final dailySession = entry.value;

                        if (dailySession.isCompleted) {
                          return const SizedBox.shrink();
                        }
                        if (dailySession.remainingTasks == 0 &&
                            dailySession.completedTasks == 0) {
                          return const SizedBox.shrink();
                        }

                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () async {
                            final dailyEntity = await TaskService()
                                .getDailyTasks(dailySession.gradeId);
                            if (dailyEntity != null) {
                              if (!context.mounted) return;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DailyTestScreen(dailyEntity: dailyEntity),
                                ),
                              );
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                            child: Container(
                              padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Сабақ ${index + 1}",
                                        style: TextStyles.regular(
                                          AppColors.black,
                                          fontSize: 9,
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        width: 34,
                                        height: 34,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.fiolet,
                                        ),
                                        child: const Icon(
                                          Icons.arrow_forward_ios,
                                          color: AppColors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // const SizedBox(height: 8),
                                  Text(
                                    dailySession.subjectName,
                                    style: TextStyles.semibold(
                                      AppColors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      _DailyInfoPill(
                                        icon: Icons.calendar_today_outlined,
                                        label:
                                            "${dailySession.completedTasks}/${dailySession.totalTasks} тапсырма",
                                      ),
                                      if (dailySession.remainingTasks > 0) ...[
                                        const SizedBox(width: 12),
                                        _DailyInfoPill(
                                          icon: Icons.timer_outlined,
                                          label:
                                              "${dailySession.remainingTasks} қалды",
                                        ),
                                      ],
                                    ],
                                  ),
                                  if (dailySession.totalTasks > 0) ...[
                                    const SizedBox(height: 12),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: LinearProgressIndicator(
                                        value:
                                            (dailySession.completedTasks /
                                                    dailySession.totalTasks)
                                                .clamp(0.0, 1.0),
                                        backgroundColor:
                                            AppColors.grey.withOpacity(0.35),
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                          AppColors.fiolet,
                                        ),
                                        minHeight: 6,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _DailyInfoPill extends StatelessWidget {
  const _DailyInfoPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: AppColors.fiolet.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColors.white,
            size: 14,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyles.regular(
            AppColors.black,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color.withOpacity(0.9),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
