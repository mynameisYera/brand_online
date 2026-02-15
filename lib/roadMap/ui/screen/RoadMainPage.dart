import 'dart:io';

import 'package:brand_online/core/app_colors.dart';
import 'package:brand_online/core/text_styles.dart';
import 'package:brand_online/roadMap/ui/screen/Math1Screen.dart';
import 'package:brand_online/roadMap/ui/screen/YoutubeScreen.dart';
import 'package:brand_online/roadMap/ui/widget/letsgo_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:dio/dio.dart';
import 'package:brand_online/core/notification/firebase_utils.dart';
import 'package:brand_online/roadMap/ui/screen/subscription_for_android.dart';
import 'package:brand_online/roadMap/ui/screen/subscription_page.dart';

import '../../../authorization/entity/ProfileResponse.dart';
import '../../../authorization/entity/RoadMapResponse.dart';
import '../../../authorization/service/auth_service.dart';
import '../../../general/GeneralUtil.dart';
import '../../entity/ProfileController.dart';
import '../../entity/SimpleTaskIndex.dart';
import '../../entity/SubjectModel.dart';
import '../../ui/widget/RoadWidget.dart';
import 'ChaptersDialog.dart';
import 'CustomAppBar.dart';
import 'RoadMap.dart';
import 'web_view_page.dart';
import 'dart:convert';

class RoadMainPage extends StatefulWidget {
  final double initialScrollOffset;
  final int state;

  const RoadMainPage(
      {super.key, this.initialScrollOffset = 0.0, required this.state});

  @override
  State<StatefulWidget> createState() => _RoadMainPageState();
}

class _RoadMainPageState extends State<RoadMainPage>
    with TickerProviderStateMixin {
  bool isLoading = true;
  bool hasNoSubscription = false;
  String noSubTitle = '';
  String noSubMessage = '';
  String noSubButtonText = '';
  String noSubWhatsAppUrl = '';
  // final _storage = const FlutterSecureStorage();

  List<Color> colors = [
    Color.fromRGBO(75, 167, 255, 1.0),
    Color.fromRGBO(141, 223, 84, 1.0),
    Color.fromRGBO(211, 157, 255, 1.0),
    Color.fromRGBO(255, 130, 85, 1.0),
    Color(0xffFFCA2B),
  ];

  List<SubjectModel> myCourses = [];
  
  /// Ключи кнопок на карточке: [индекс урока][индекс шага 0..3]. Порядок шагов — из бэкенда (step_order).
  final List<List<GlobalKey>> _stepButtonKeys =
      List.generate(100, (_) => List.generate(4, (_) => GlobalKey()));

  final List<String> barysImagePaths = [
    'assets/images/A1.png',
    'assets/images/A2.png',
    'assets/images/A3.png',
    'assets/images/A4.png',
    'assets/images/A5.png',
  ];

  Map<int, double> chapterScrollPositions = {};
  List<Map<SimpleTaskIndex, List<SimpleTaskIndex>>> structuredChapters = [];
  late LessonResponse response;
  late ProfileResponse profileResponse = ProfileResponse(
    permanent_balance: 0,
    temporary_balance: 0,
    id: 1,
    role: 0,
    grade: 0,
    strike: "0",
    points: "0",
    multiplier: "0",
    selectedGrade: null,
    permanentBalance: 0,
    temporaryBalance: 0,
    gradeBalances: []
  );
  ScrollController _scrollController = ScrollController();
  int selectedIndex = -1;
  List<Widget> widgetList = [];
  bool responseNull = false;
  List<String> chapterWidget = [];
  List<String> title = [];
  List<String> chapters = [];

  List<int> tarau = [];
  List<int> takyryp = [];

  Color currentBoxColor = Color.fromRGBO(75, 167, 255, 1);
  List<double> widgetHeights = [];
  int index = 0;
  int indexColor = 0;
  String chapterTitle = '';
  String mainTitle = '';
  String mainTitleDescription = '';

  @override
  void initState() {
    super.initState();
    FirebaseUtil().initialize();
    chapterTitle = '';
    mainTitle = '';
    _scrollController.addListener(_onScroll);
    getProfile();
    getMyCourses();
    getRoadMap();
  }



  Future<void> getMyCourses() async {
    final storage = FlutterSecureStorage(
      aOptions: const AndroidOptions(encryptedSharedPreferences: true),
    );
    String? token = await storage.read(key: 'auth_token');

    if (token == null) {
      print("Token is null — getMyCourses() отменён");
      return;
    }

    final Dio _dio = Dio(BaseOptions(baseUrl: GeneralUtil.BASE_URL));
    try {
      final response = await _dio.get(
        '/edu/my-courses/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200 && response.data is List) {
        setState(() {
          myCourses = (response.data as List)
              .map((item) => SubjectModel.fromJson(item))
              .toList();
        });
      }
    } catch (e) {
      print("Ошибка при получении курсов: $e");
    }
  }


  getProfile() async {
    final storage = FlutterSecureStorage(
      aOptions: const AndroidOptions(encryptedSharedPreferences: true),
    );
    String? token = await storage.read(key: 'auth_token');

    if (token == null) {
      print("Token is null — getProfile() отменён");
      return;
    }

    AuthService().getProfile(token, context).then((res) {
      if (res != null) {
        ProfileController.updateFromProfile(res);
        profileResponse = res;
        savePreferences(res.points);
      } else {
        print('Profile response is null');
      }
    }).then((_) {
      setState(() {
        print(profileResponse);
      });
    });
  }


  void savePreferences(String accessToken) async {
    final storage = FlutterSecureStorage(
      aOptions: const AndroidOptions(
        encryptedSharedPreferences: true,
      ),
    );
    await storage.write(key: 'points', value: accessToken);

  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> getRoadMap() async {
    setState(() {
      isLoading = true;
    });

    final storage = FlutterSecureStorage(
      aOptions: const AndroidOptions(
        encryptedSharedPreferences: true,
      ),
    );
    String? token = await storage.read(key: 'auth_token');


    final delay = Future.delayed(const Duration(seconds: 0));
    final responseFuture = AuthService().getRoadMap(token!, context);

    final results = await Future.wait([responseFuture, delay]);

    final res = results[0] as LessonResponse?;

    if (res != null) {
      print('RoadMap Response JSON:');
      print(JsonEncoder.withIndent('  ').convert(res.toJson()));
      if (res.hasNoSubscription) {
        setState(() {
          hasNoSubscription = true;
          noSubTitle = res.noSubTitle!;
          noSubMessage = res.noSubMessage!;
          noSubButtonText = res.noSubButtonText!;
          noSubWhatsAppUrl = res.noSubWhatsAppUrl!;
          isLoading = false;
        });
        return;
      }
      setState(() {
        response = res;
        widgetList = [];
        chapterWidget = [];
        index = 0;
        widgetHeights = [];
        takyryp = [];
        tarau = [];
        double currentOffset = 0.0;
        structuredChapters.clear();

        for (var chapter in response.chapters) {
          List<SimpleTaskIndex> lessonsList = [];
          int chapterId = chapter.chapterNumber;
          String chapterTitle = chapter.chapterName;

          chapterWidget.add(chapterTitle);

          for (var lesson in chapter.lessons) {
            String lessonTitle = lesson.lessonTitle;
            int lessonId = lesson.lessonNumber;
            takyryp.add(lessonId);
            tarau.add(chapterId);
            title.add(lessonTitle);
            chapters.add(chapterTitle);
            chapterScrollPositions[widgetList.length] = currentOffset;

            widgetList.add(
              _buildLessonCard(
                context,
                lesson,
                index,
                lesson.videoWatched == false
                    ? Colors.grey
                    : colors[index % 5],
              ),
            );
            
            currentOffset += 380;
            index++;
            lessonsList.add(SimpleTaskIndex(title: lessonTitle, index: lessonId, isCompleted: lesson.videoWatched && lesson.group1Completed && lesson.group2Completed && lesson.group3Completed, isCashback: lesson.cashbackActive));
          }
          structuredChapters.add({
            SimpleTaskIndex(title: chapterTitle, index: chapterId, isCompleted: lessonsList.every((lesson) => lesson.isCompleted), isCashback: lessonsList.any((lesson) => lesson.isCashback)): lessonsList,
          });
        }

        widgetList = widgetList.reversed.toList();
        if (title.isNotEmpty &&
            chapters.isNotEmpty &&
            tarau.isNotEmpty &&
            takyryp.isNotEmpty) {
          chapterTitle = title[0];
          mainTitle = chapters[0];
          mainTitleDescription = "Тарау ${tarau[0]}, Сабақ ${takyryp[0]}";
        } else {
          chapterTitle = '';
          mainTitle = '';
          mainTitleDescription = '';
        }

        if (mounted) {
          int greyIndex = findLastGreyIndex();
          int cashbackActiveIndex = findCashbackIndex();
          if (cashbackActiveIndex != -1) {
            Future.delayed(Duration(milliseconds: 300), () {
              _scrollController.animateTo(
                cashbackActiveIndex * 380,
                duration: Duration(milliseconds: 600),
                curve: Curves.easeInOut,
              );
            });
          } else if (greyIndex != -1) {
            Future.delayed(Duration(milliseconds: 300), () {
              _scrollController.animateTo(
                greyIndex * 380,
                duration: Duration(milliseconds: 600),
                curve: Curves.easeInOut,
              );
            });
          }
        }

        if (widgetList.isEmpty) responseNull = true;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildLessonCard(
    BuildContext context,
    Lesson lesson,
    int index,
    Color color,
  ) {
    final characterImage = lesson.cashbackActive
        ? 'assets/images/moneyadm.png'
        : barysImagePaths[index % 5];

    final bool allCompleted = lesson.hasActions
        ? lesson.actions.every((a) => a.isCompleted)
        : lesson.effectiveStepOrder.every((s) => lesson.isStepCompleted(s));

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      width: double.infinity,
      height: 360,
      decoration: BoxDecoration(
        color: colors[index % 5],
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: AssetImage(characterImage),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          if (!allCompleted)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          Column(
            children: [
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: lesson.hasActions
                    ? _buildActionButtons(context, lesson, index)
                    : _buildStepButtons(context, lesson, index, lesson.effectiveStepOrder),
              ),
              SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }

  /// До 4 кнопок по actions: video → YoutubeScreen, materials → WebViewPage/MaterialsPage, task_group → тест.
  List<Widget> _buildActionButtons(BuildContext context, Lesson lesson, int index) {
    final ordered = List<LessonAction>.from(lesson.actions)
      ..sort((a, b) => a.order.compareTo(b.order));
    final list = <Widget>[];
    for (int i = 0; i < ordered.length && i < 4; i++) {
      final action = ordered[i];
      final key = index < _stepButtonKeys.length && i < _stepButtonKeys[index].length
          ? _stepButtonKeys[index][i]
          : GlobalKey();
      final isActive = action.isCompleted;
      final previousDone = ordered.take(i).every((a) => a.isCompleted);
      final iconPath = _iconPathForActionType(action.actionType);
      final showCashback = lesson.cashbackActive && !action.isCompleted && action.actionType == 'task_group';
      list.add(_buildCardButton(
        context: context,
        lesson: lesson,
        index: index,
        buttonKey: key,
        isActive: isActive,
        iconPath: iconPath,
        showCashback: showCashback,
        onTap: () => _onActionTap(context, lesson, index, action, previousDone),
      ));
    }
    return list;
  }

  String _iconPathForActionType(String actionType) {
    switch (actionType) {
      case 'video':
        return 'assets/icons/play.svg';
      case 'materials':
        return 'assets/icons/materials.svg';
      case 'task_group':
        return 'assets/icons/problems.svg';
      default:
        return 'assets/icons/play.svg';
    }
  }

  void _onActionTap(BuildContext context, Lesson lesson, int cardIndex, LessonAction action, bool previousDone) {
    if (lesson.isPublished == false) {
      showModalBottomSheet(
        context: context,
        builder: (ctx) => LetsgoPopup(
          title: 'Кеттік!',
          subtitle: 'Кеттік!',
          onContinue: () => Navigator.pop(ctx),
        ),
      );
      return;
    }
    if (!previousDone) {
      RoadWidget().showTaskDoneDialog(context);
      return;
    }
    switch (action.actionType) {
      case 'video':
        _openActionVideo(context, lesson, action);
        break;
      case 'materials':
        _openActionMaterials(context, lesson, action);
        break;
      case 'task_group':
        _openActionTaskGroup(context, lesson, action);
        break;
      default:
        break;
    }
  }

  void _openActionVideo(BuildContext context, Lesson lesson, LessonAction action) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => LetsgoPopup(
        title: 'Видеосабақты көру',
        subtitle: 'Сабақты бастауға дайынсыз ба?',
        onContinue: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (c) => YoutubeScreen(
                lesson: lesson,
                videoUrlOverride: action.videoUrl,
              ),
            ),
          );
          if (!context.mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => RoadMap(initialScrollOffset: _scrollController.offset, selectedIndx: 0, state: 0),
            ),
            (route) => false,
          );
        },
      ),
    );
  }

  void _openActionMaterials(BuildContext context, Lesson lesson, LessonAction action) {
    if (action.materials.isEmpty) return;
    if (action.materials.length == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WebViewPage(url: action.materials.first.url, isAction: true, lessonId: lesson.lessonId, actionId: action.actionId),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WebViewPage(url: action.materials.first.url, isAction: true, lessonId: lesson.lessonId, actionId: action.actionId),
      ),
    );
  }

  void _openActionTaskGroup(BuildContext context, Lesson lesson, LessonAction action) {
    if (action.taskGroup == null) return;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => LetsgoPopup(
        title: lesson.lessonTitle,
        subtitle: 'Сабақты бастауға дайынсыз ба?',
        onContinue: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (c) => Math1Screen(
                initialScrollOffset: _scrollController.offset,
                lessonId: lesson.lessonId,
                groupId: action.taskGroup!,
                cashbackActive: lesson.cashbackActive,
                isCash: false,
                lesson: lesson,
              ),
            ),
          );
          if (!context.mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => RoadMap(initialScrollOffset: _scrollController.offset, selectedIndx: 0, state: 0),
            ),
            (route) => false,
          );
        },
      ),
    );
  }

  /// Строит кнопки по порядку из бэкенда (step_order): видео и group_1..group_3.
  List<Widget> _buildStepButtons(
    BuildContext context,
    Lesson lesson,
    int index,
    List<String> stepOrder,
  ) {
    final list = <Widget>[];
    for (int stepIndex = 0; stepIndex < stepOrder.length && stepIndex < 4; stepIndex++) {
      final stepType = stepOrder[stepIndex];
      final key = index < _stepButtonKeys.length && stepIndex < _stepButtonKeys[index].length
          ? _stepButtonKeys[index][stepIndex]
          : GlobalKey();
      final isActive = lesson.isStepCompleted(stepType);
      final previousDone = lesson.arePreviousStepsCompleted(stepIndex);

      if (stepType == 'video') {
        list.add(_buildCardButton(
          context: context,
          lesson: lesson,
          index: index,
          buttonKey: key,
          isActive: isActive,
          iconPath: 'assets/icons/play.svg',
          onTap: () => _onVideoStepTap(context, lesson),
        ));
      } else {
        final groupId = stepType == 'group_1' ? 1 : stepType == 'group_2' ? 2 : 3;
        final groupCompleted = lesson.isStepCompleted(stepType);
        list.add(_buildCardButton(
          context: context,
          lesson: lesson,
          index: index,
          buttonKey: key,
          isActive: groupCompleted,
          iconPath: 'assets/icons/problems.svg',
          showCashback: lesson.cashbackActive && !groupCompleted,
          onTap: () => _onGroupStepTap(context, lesson, groupId, previousDone),
        ));
      }
    }
    return list;
  }

  void _onVideoStepTap(BuildContext context, Lesson lesson) {
    if (lesson.isPublished == false) {
      showModalBottomSheet(
        context: context,
        builder: (ctx) => LetsgoPopup(
          title: 'Кеттік!',
          subtitle: 'Кеттік!',
          onContinue: () => Navigator.pop(ctx),
        ),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      builder: (ctx) => LetsgoPopup(
        title: 'Видеосабақты көру',
        subtitle: 'Сабақты бастауға дайынсыз ба?',
        onContinue: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (c) => YoutubeScreen(lesson: lesson),
            ),
          );
          if (!context.mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => RoadMap(initialScrollOffset: _scrollController.offset, selectedIndx: 0, state: 0),
            ),
            (route) => false,
          );
        },
      ),
    );
  }

  void _onGroupStepTap(BuildContext context, Lesson lesson, int groupId, bool previousDone) {
    if (lesson.isPublished == false) {
      RoadWidget().showUndefinedDialog(context);
      return;
    }
    if (!previousDone) {
      if (!lesson.videoWatched) {
        RoadWidget().showWatchVideoDialog(context);
      } else {
        RoadWidget().showTaskDoneDialog(context);
      }
      return;
    }
    showModalBottomSheet(
      context: context,
      builder: (ctx) => LetsgoPopup(
        title: lesson.lessonTitle,
        subtitle: 'Сабақты бастауға дайынсыз ба?',
        onContinue: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (c) => Math1Screen(
                initialScrollOffset: _scrollController.offset,
                lessonId: lesson.lessonId,
                groupId: groupId,
                cashbackActive: lesson.cashbackActive,
                isCash: false,
                lesson: lesson,
              ),
            ),
          );
          if (!context.mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => RoadMap(initialScrollOffset: _scrollController.offset, selectedIndx: 0, state: 0),
            ),
            (route) => false,
          );
        },
      ),
    );
  }

  Widget _buildCardButton({
    required BuildContext context,
    required Lesson lesson,
    required int index,
    required GlobalKey buttonKey,
    required bool isActive,
    required String iconPath,
    required VoidCallback onTap,
    bool showCashback = false,
  }) {
    Color buttonColor;
    if (isActive) {
      buttonColor = colors[index % 5];
    } else if (lesson.cashbackActive) {
      buttonColor = Colors.amber;
    } else {
      buttonColor = Color(0xffF1F1F1);
    }

    return GestureDetector(
      key: buttonKey,
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: SizedBox(
                width: 36,
                height: 36,
                child: SvgPicture.asset(
                  iconPath,
                  fit: BoxFit.contain,
                  color: isActive || lesson.cashbackActive
                      ? AppColors.white
                      : AppColors.grey,
                ),
              ),
            ),
            if (showCashback)
              Positioned(
                top: 45,
                right: 0,
                child: Image.asset(
                  'assets/images/dollar.png',
                  width: 18,
                  height: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _onScroll() {
    if (widgetList.isEmpty) return;

    double offset = _scrollController.position.pixels;
    int newChapterIndex = ((offset + 350) / 380).floor(); // Обновлено под новую высоту карточки

    if (newChapterIndex != selectedIndex) {
      setState(() {
        selectedIndex = newChapterIndex;
        chapterTitle = title[selectedIndex];
        mainTitle = chapters[selectedIndex];
        mainTitleDescription =
        "Тарау ${tarau[selectedIndex]}, Сабақ ${takyryp[selectedIndex]}";
        currentBoxColor = colors[newChapterIndex % colors.length];
      });
    }
  }

  Widget roadFromRight(BuildContext context, Lesson lesson, int index,
      Color color) {
    return SizedBox(
      height: 530,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            lesson.cashbackActive
                ? Expanded(
                    child: Image.asset('assets/images/moneyadm.png',
                        fit: BoxFit.cover))
                : Expanded(
                    child: Image.asset(barysImagePaths[index % 5],
                        fit: BoxFit.cover)),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 40,
                ),
                Padding(
                  padding: EdgeInsets.only(
                      right: MediaQuery
                          .of(context)
                          .size
                          .width * 0.3),
                  child: GestureDetector(
                    key: _stepButtonKeys[index][3],
                    onTap: () async {
                      (lesson.isPublished == false)
                          ? RoadWidget().showUndefinedDialog(context)
                          : (lesson.videoWatched != true)
                          ? RoadWidget().showWatchVideoDialog(context)
                          : (lesson.group1Completed &&
                          lesson.group2Completed)
                          ? await RoadWidget()
                          .math1(context, index,
                          _stepButtonKeys[index][3], lesson, 3,
                          scrollOffset:
                          _scrollController.offset, false)
                          .then(
                            (value) {
                          if (value == true) {
                            getRoadMap();
                          }
                        },
                      )
                          : RoadWidget().showTaskDoneDialog(context);
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: lesson.group3Completed
                                ? colors[index % 5].withOpacity(0.4)
                                : lesson.cashbackActive
                                ? Colors.amber.withOpacity(0.4) : Colors.grey.withOpacity(0.4),
                            offset: Offset(0, 10),
                            blurRadius: 1,
                          ),
                        ],
                        color: (lesson.group3Completed
                            ? colors[index % 5]
                            : lesson.cashbackActive
                            ? Colors.amber : Colors.grey),
                      ),
                      child: Center(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            SizedBox(
                              width: 50,
                              height: 50,
                              child: Image.asset(
                                'assets/images/formula.png',
                                fit: BoxFit.contain,
                                color: Colors.white,
                              ),
                            ),
                            if (lesson.cashbackActive && lesson.group3Completed == false)
                              Positioned(
                                top: 40,
                                left: 50,
                                child: Image.asset(
                                  'assets/images/dollar.png',
                                  width: 20,
                                  height: 20,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40),
                GestureDetector(
                  key: _stepButtonKeys[index][2],
                  onTap: () async {
                    (lesson.isPublished == false)
                        ? RoadWidget().showUndefinedDialog(context)
                        : (lesson.videoWatched != true)
                        ? RoadWidget().showWatchVideoDialog(context)
                        : (!lesson.group1Completed)
                        ? RoadWidget().showTaskDoneDialog(context)
                        : await RoadWidget()
                        .math1(
                      context,
                      index,
                      _stepButtonKeys[index][2],
                      lesson,
                      2, false,
                      scrollOffset: _scrollController.offset,
                    )
                        .then(
                          (value) {
                        if (value == true) {
                          getRoadMap();
                        }
                      },
                    );
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: lesson.group2Completed
                              ? colors[index % 5].withOpacity(0.4)
                              : lesson.cashbackActive
                              ? Colors.amber.withOpacity(0.4) : Colors.grey
                              .withOpacity(0.4),
                          offset: Offset(0, 10),
                          blurRadius: 1,
                        ),
                      ],
                      color:
                      (lesson.group2Completed
                          ? colors[index % 5]
                          : lesson.cashbackActive
                          ? Colors.amber : Colors.grey),
                    ),
                    child: Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: Image.asset(
                              'assets/images/function.png',
                              fit: BoxFit.contain,
                              color: Colors.white,
                            ),
                          ),
                          if (lesson.cashbackActive && lesson.group2Completed == false)
                            Positioned(
                              top: 40,
                              left: 50,
                              child: Image.asset(
                                'assets/images/dollar.png',
                                width: 20,
                                height: 20,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40),
                GestureDetector(
                  key: _stepButtonKeys[index][1],
                  onTap: () async {
                    (lesson.isPublished == false)
                        ? RoadWidget().showUndefinedDialog(context)
                        : (lesson.videoWatched)
                        ? await RoadWidget()
                        .math1(
                      context,
                      index,
                      _stepButtonKeys[index][1],
                      lesson,
                      1, false,
                      scrollOffset: _scrollController.offset,
                    )
                        .then(
                          (value) {
                        if (value == true) {
                          getRoadMap();
                        }
                      },
                    )
                        : RoadWidget().showWatchVideoDialog(context);
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:  (lesson.group1Completed
                              ? colors[index % 5]
                              : lesson.cashbackActive
                              ? Colors.amber.withOpacity(0.4)
                              : Colors.grey)
                              .withOpacity(0.4),
                          offset: Offset(0, 10),
                          blurRadius: 1,
                        ),
                      ],
                      color:(lesson.group1Completed
                          ? colors[index % 5]
                          : lesson.cashbackActive
                          ? Colors.amber : Colors.grey),
                    ),
                    child: Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: Image.asset(
                              'assets/images/maths.png',
                              fit: BoxFit.contain,
                              color: Colors.white,
                            ),
                          ),
                          if (lesson.cashbackActive && lesson.group1Completed == false)
                            Positioned(
                              top: 40,
                              left: 50,
                              child: Image.asset(
                                'assets/images/dollar.png',
                                width: 20,
                                height: 20,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40),
                Padding(
                  padding: EdgeInsets.only(
                      right: MediaQuery
                          .of(context)
                          .size
                          .width * 0.3),
                  child: GestureDetector(
                    key: _stepButtonKeys[index][0],
                    onTap: () async {
                      (lesson.isPublished == false)
                          ? RoadWidget().showUndefinedDialog(context)
                          : await RoadWidget()
                          .playDialogScreen(
                        context,
                        index,
                        _stepButtonKeys[index][0],
                        lesson,
                        scrollOffset: _scrollController.offset,
                      )
                          .then((value) {
                        if (value == true) {
                          getRoadMap();
                        }
                      });
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: lesson.videoWatched
                                ? colors[index % 5].withOpacity(0.4)
                                : Colors.grey.withOpacity(0.4),
                            offset: Offset(0, 10),
                            blurRadius: 1,
                          ),
                        ],
                        color: lesson.videoWatched
                            ? colors[index % 5]
                            : Colors.grey,
                      ),
                      child: Center(
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: Image.asset(
                            'assets/images/play-button.png',
                            fit: BoxFit.contain,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget roadFromLeft(BuildContext context, Lesson lesson, int index,
      Color color) {
    return SizedBox(
      height: 530,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              SizedBox(height: 40),
              // Math 1
              Padding(
                padding: EdgeInsets.only(
                    left: MediaQuery
                        .of(context)
                        .size
                        .width * 0.3),
                child: GestureDetector(
                  key: _stepButtonKeys[index][3],
                  onTap: () async {
                    (lesson.isPublished == false)
                        ? RoadWidget().showUndefinedDialog(context)
                        : (lesson.videoWatched != true)
                        ? RoadWidget().showWatchVideoDialog(context)
                        : (lesson.group1Completed && lesson.group2Completed)
                        ? await RoadWidget()
                        .math1(
                      context,
                      index,
                      _stepButtonKeys[index][3],
                      lesson,
                      3, true,
                      scrollOffset: _scrollController.offset,
                    )
                        .then(
                          (value) {
                        if (value == true) {
                          getRoadMap();
                        }
                      },
                    )
                        : RoadWidget().showTaskDoneDialog(context);
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: lesson.group3Completed
                              ? colors[index % 5].withOpacity(0.4)
                              : lesson.cashbackActive
                              ? Colors.amber.withOpacity(0.4)
                              : lesson.cashbackActive
                              ? Colors.yellow.withOpacity(0.4)
                              : Colors.grey.withOpacity(0.4),
                          offset: Offset(0, 10),
                          blurRadius: 1,
                        ),
                      ],
                      color: lesson.group3Completed
                          ? colors[index % 5]
                          : lesson.cashbackActive
                          ? Colors.amber
                          : Colors.grey,
                    ),
                    child: Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: Image.asset(
                              'assets/images/formula.png',
                              fit: BoxFit.contain,
                              color: Colors.white,
                            ),
                          ),
                          if (lesson.cashbackActive && lesson.group3Completed == false)
                            Positioned(
                              top: 40,
                              left: 50,
                              child: Image.asset(
                                'assets/images/dollar.png',
                                width: 20,
                                height: 20,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40),
              // Math 2
              GestureDetector(
                key: _stepButtonKeys[index][2],
                onTap: () async {
                  (lesson.isPublished == false)
                      ? RoadWidget().showUndefinedDialog(context)
                      : (lesson.videoWatched != true)
                      ? RoadWidget().showWatchVideoDialog(context)
                      : (!lesson.group1Completed)
                      ? RoadWidget().showTaskDoneDialog(context)
                      : await RoadWidget()
                      .math1(
                    context,
                    index,
                    _stepButtonKeys[index][2],
                    lesson,
                    2, true,
                    scrollOffset: _scrollController.offset,
                  )
                      .then(
                        (value) {
                      if (value == true) {
                        getRoadMap();
                      }
                    },
                  );
                },
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: lesson.group2Completed
                            ? colors[index % 5].withOpacity(0.4)
                            : lesson.cashbackActive
                            ? Colors.amber.withOpacity(0.4)
                            : Colors.grey.withOpacity(0.4),
                        offset: Offset(0, 10),
                        blurRadius: 1,
                      ),
                    ],
                    color: lesson.group2Completed
                        ? colors[index % 5]
                        : lesson.cashbackActive
                        ? Colors.amber
                        : Colors.grey,
                  ),
                  child: Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: Image.asset(
                            'assets/images/function.png',
                            fit: BoxFit.contain,
                            color: Colors.white,
                          ),
                        ),
                        if (lesson.cashbackActive && lesson.group2Completed == false)
                          Positioned(
                            top: 40,
                            left: 50,
                            child: Image.asset(
                              'assets/images/dollar.png',
                              width: 20,
                              height: 20,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40),
              // Math 3
              GestureDetector(
                key: _stepButtonKeys[index][1],
                onTap: () async {
                  (lesson.isPublished == false)
                      ? RoadWidget().showUndefinedDialog(context)
                      : (lesson.videoWatched)
                      ? await RoadWidget()
                      .math1(
                    context,
                    index,
                    _stepButtonKeys[index][1],
                    lesson,
                    1, true,
                    scrollOffset: _scrollController.offset,
                  )
                      .then(
                        (value) {
                      if (value == true) {
                        getRoadMap();
                      }
                    },
                  )
                      : RoadWidget().showWatchVideoDialog(context);
                },
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: lesson.group1Completed
                            ? colors[index % 5].withOpacity(0.4)
                            : lesson.cashbackActive
                            ? Colors.amber.withOpacity(0.4)
                            : Colors.grey.withOpacity(0.4),
                        offset: Offset(0, 10),
                        blurRadius: 1,
                      ),
                    ],
                    color: lesson.group1Completed
                        ? colors[index % 5]
                        : lesson.cashbackActive
                        ? Colors.amber
                        : Colors.grey,
                  ),
                  child: Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: Image.asset(
                            'assets/images/maths.png',
                            fit: BoxFit.contain,
                            color: Colors.white,
                          ),
                        ),
                        if (lesson.cashbackActive && lesson.group1Completed == false)
                          Positioned(
                            top: 40,
                            left: 50,
                            child: Image.asset(
                              'assets/images/dollar.png',
                              width: 20,
                              height: 20,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40),
              // Play Icon
              Padding(
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.3
                  ),
                child: GestureDetector(
                  key: _stepButtonKeys[index][0],
                  onTap: () async {
                    (lesson.isPublished == false)
                        ? RoadWidget().showUndefinedDialog(context)
                        : await RoadWidget()
                        .playDialogScreen(
                      context,
                      index,
                      _stepButtonKeys[index][0],
                      lesson,
                      scrollOffset: _scrollController.offset,
                    )
                        .then((value) {
                      if (value == true) {
                        getRoadMap();
                      }
                    });
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: lesson.videoWatched
                              ? colors[index % 5].withOpacity(0.4)
                              : Colors.grey.withOpacity(0.4),
                          offset: Offset(0, 10),
                          blurRadius: 1,
                        ),
                      ],
                      color:
                      lesson.videoWatched ? colors[index % 5] : Colors.grey,
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: Image.asset(
                          'assets/images/play-button.png',
                          fit: BoxFit.contain,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
          lesson.cashbackActive
              ? Expanded(
                  child: Image.asset('assets/images/moneyadm.png',
                      fit: BoxFit.cover))
              : Expanded(
                  child: Image.asset(barysImagePaths[index % 5],
                      fit: BoxFit.cover)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width * 0.9;

    if (hasNoSubscription) {
      // android 
      // return SubscriptionForAndroid(
      //   whatsappUrl: noSubWhatsAppUrl,
      // );
      return Platform.isAndroid ?
       SubscriptionForAndroid(
        whatsappUrl: noSubWhatsAppUrl,
      ) : SubscriptionPage();

      // return NoSubPageIos(whatsappUrl: noSubWhatsAppUrl);
      //       title: noSubTitle,
      //       message: noSubMessage,
      //       buttonMessage: noSubButtonText,
      //       whatsappUrl: noSubWhatsAppUrl,
    } else if (widgetList.isEmpty && responseNull == false) {
      return Scaffold(
          backgroundColor: Colors.white,
          body: SizedBox.expand(
            child: Center(
              child: LoadingAnimationWidget.progressiveDots(
                color: GeneralUtil.mainColor,
                size: MediaQuery
                    .of(context)
                    .size
                    .width * 0.2,
              ),
            ),
          ));
    }

    return (isLoading)
        ? Scaffold(
        backgroundColor: Colors.white,
        body: SizedBox.expand(
            child: Center(
              child: LoadingAnimationWidget.progressiveDots(
                color: GeneralUtil.mainColor,
                size: MediaQuery
                    .of(context)
                    .size
                    .width * 0.2,
              ),
            )))
        : Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.transparent,
      body: Center(
        child: SizedBox(
          width: screenWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CustomAppBar(),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: InkWell(
                  onTap: () => _showSubjectList(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: SvgPicture.asset("assets/icons/burger.svg", width: 18, height: 18),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            profileResponse.selectedGrade?.subjectName ?? '-',
                            style: TextStyles.bold(AppColors.white),
                          ),
                        ],
                      ),
                      if (profileResponse.selectedGrade?.cashbackPending == true)
                        Image.asset(
                          'assets/images/dollar.png',
                          width: 20,
                          height: 20,
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ChaptersDialog(data: structuredChapters),
                    ),
                  ).then((result) {
                    if (result != null && result is Map<String, String>) {
                      final chapter = result['chapter'];
                      final titleName = result['title'];
                      final scrollIndex =
                      findIndexForScroll(chapter, titleName);
                      if (scrollIndex != -1) {
                        _scrollController.animateTo(
                          scrollIndex * 380,
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      }
                    }
                  });
                },
                child: Center(
                  child: AnimatedContainer(
                    key: ValueKey<int>(selectedIndex),
                    duration: Duration(milliseconds: 500),
                    width: screenWidth,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primaryBlue, width: 2),
                    ),
                    child: Row(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                mainTitleDescription,
                                textAlign: TextAlign.left,
                                style: TextStyles.medium(AppColors.grey),
                              ),
                            SizedBox(height: 4),
                            Text(
                              textAlign: TextAlign.left,
                              chapterTitle.length > 30 ? chapterTitle.substring(0, 30) + '..' : chapterTitle,
                              style: TextStyles.medium(AppColors.black),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                        Spacer(),
                        Icon(Icons.keyboard_arrow_down_outlined, color: AppColors.grey),
                      ],
                    )
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  reverse: true,
                  child: Column(
                    children: widgetList
                        .map((widget) => SizedBox(child: widget))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSubjectList(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'SubjectList',
      barrierColor: Colors.black38,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (_, anim, __, child) {
        final t = Curves.easeOut.transform(anim.value);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, -300 + 300 * t),
            child: Align(
              alignment: Alignment.topCenter,
              child: SafeArea(
                child: Material(
                  color: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(16)),
                  ),
                  elevation: 8,
                  child: Container(
                    height: myCourses.length * 64.0 + 16,
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ListView.builder(
                      itemCount: myCourses.length,
                      itemBuilder: (ctx, i) {
                        final course = myCourses[i];
                        final color = colors[i % colors.length];
                        return GestureDetector(
                          onTap: () async {
                            await setGrade(course.id);
                            Navigator.of(context).pop();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    RoadMap(selectedIndx: 0, state: 0),
                              ),
                            );
                          },
                          child: Container(
                            height: 56,
                            margin: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '${course.name}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    course.subjectName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (course.cashbackPending == true)
                                  Image.asset(
                                    'assets/images/dollar.png',
                                    width: 20,
                                    height: 20,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> setGrade(int gradeId) async {
    final storage = FlutterSecureStorage(
      aOptions: const AndroidOptions(
        encryptedSharedPreferences: true,
      ),
    );
    String? token = await storage.read(key: 'auth_token');


    final Dio dio = Dio(BaseOptions(baseUrl: GeneralUtil.BASE_URL));
    try {
      await dio.post(
        '/edu/my-courses/set-grade/$gradeId/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
    } catch (e) {
      print("Ошибка при установке класса: $e");
    }
  }

  int findLastGreyIndex() {
    for (int i = 0; i < response.chapters.length; i++) {
      final chapter = response.chapters[i];
      for (int j = 0; j < chapter.lessons.length; j++) {
        final lesson = chapter.lessons[j];
        if (!lesson.videoWatched ||
            !lesson.group1Completed ||
            !lesson.group2Completed ||
            !lesson.group3Completed) {
          return (response.chapters
              .take(i)
              .fold(0, (prev, element) => prev + element.lessons.length)) +
              j;
        }
      }
    }
    return -1;
  }

  int findCashbackIndex() {
    for (int i = 0; i < response.chapters.length; i++) {
      final chapter = response.chapters[i];
      for (int j = 0; j < chapter.lessons.length; j++) {
        final lesson = chapter.lessons[j];
        if (lesson.cashbackActive
            &&
            (!lesson.group1Completed ||
            !lesson.group2Completed ||
            !lesson.group3Completed)) {
          return (response.chapters
              .take(i)
              .fold(0, (prev, element) => prev + element.lessons.length)) +
              j;
        }
      }
    }
    return -1;
  }

  int findIndexForScroll(String? chapter, String? titleName) {
    for (int i = 0; i < title.length; i++) {
      if (chapters[i] == chapter && title[i] == titleName) {
        return i;
      }
    }
    return -1;
  }



  // ignore: unused_element
  Widget _subjectChip(String grade, String title, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              grade,
              style: TextStyle(fontSize: 12, color: Colors.white,fontWeight: FontWeight.bold,),
            ),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
