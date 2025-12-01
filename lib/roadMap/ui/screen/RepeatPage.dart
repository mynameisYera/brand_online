import 'package:flutter/material.dart';
import 'package:brand_online/authorization/entity/RoadMapResponse.dart';
import 'package:brand_online/roadMap/ui/screen/NoTaskPage.dart';
import 'package:brand_online/roadMap/ui/screen/YoutubeUrlScreen.dart';
import '../../../general/GeneralUtil.dart';
import '../../entity/ControlExam.dart';
import '../../entity/DailyReview.dart';
import '../widget/DailyReviewCard.dart';
import 'CustomAppBar.dart';
import 'Math1Screen.dart';
import '../../service/task_service.dart';
import '../../entity/RestartLesson.dart';
import 'RepeatTaskScreen.dart';

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

  bool responseNull = false;
  bool controlExamStarted = false;
  bool _loading = true;
  bool _hasAny = false;
  int? expandedIndex;

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

      setState(() {
        lessons     = ls;
        controlExam = exam;
        dailyReview = dr;
        _hasAny = ls.isNotEmpty || (exam?.isOpen ?? false) || (dr?.isOpen ?? false);
        _loading = false;
        responseNull = result == null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        lessons = [];
        controlExam = null;
        dailyReview = null;
        _hasAny = false;
        _loading = false;
        responseNull = true;
      });
    }
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

    final theme = Theme.of(context);
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
                  const SizedBox(height: 12),
                  if (controlExam?.isOpen ?? false)
                    _ControlExamCard(
                      controlExam: controlExam!,
                      started: controlExamStarted,
                      onTap: () {
                        setState(() {
                          controlExamStarted = true;
                        });
                      },
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
                    ),
                  if (dailyReview?.isOpen ?? false)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: DailyReviewTile(
                        subject: dailyReview!.subjectName,
                        isCompleted: dailyReview!.isCompleted,
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
                      ),
                    ),
                  if (lessons.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 48),
                      child: Center(
                        child: Text(
                          responseNull
                              ? "Қазір тапсырмалар қолжетімді емес"
                              : "Қайталайтын сабақтар табылмады",
                          style: theme.textTheme.bodyLarge
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
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
