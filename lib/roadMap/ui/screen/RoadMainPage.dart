import 'dart:io';

import 'package:brand_online/core/app_colors.dart';
import 'package:brand_online/core/text_styles.dart';
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
  
  final List<GlobalKey> _buttonKeys =
  List.generate(100, (index) => GlobalKey());
  final List<GlobalKey> _buttonMath1 =
  List.generate(100, (index) => GlobalKey());
  final List<GlobalKey> _buttonMath2 =
  List.generate(100, (index) => GlobalKey());
  final List<GlobalKey> _buttonMath3 =
  List.generate(100, (index) => GlobalKey());

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

            widgetList.add((index.isEven)
                ? roadFromRight(
                context,
                lesson,
                index,
                lesson.videoWatched == false
                    ? Colors.grey
                    : colors[index % 5])
                : roadFromLeft(
                context,
                lesson,
                index,
                lesson.videoWatched == false
                    ? Colors.grey
                    : colors[index % 5]));
            widgetList.add(_spaceBreaker(lesson.lessonTitle));
            currentOffset += 530 + 40;
            index++;
            lessonsList
                .add(SimpleTaskIndex(title: lessonTitle, index: lessonId));
          }
          structuredChapters.add({
            SimpleTaskIndex(title: chapterTitle, index: chapterId): lessonsList,
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
                cashbackActiveIndex * 585,
                duration: Duration(milliseconds: 600),
                curve: Curves.easeInOut,
              );
            });
          } else if (greyIndex != -1) {
            Future.delayed(Duration(milliseconds: 300), () {
              _scrollController.animateTo(
                greyIndex * 585,
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

  void _onScroll() {
    if (widgetList.isEmpty) return;

    double offset = _scrollController.position.pixels;
    int newChapterIndex = ((offset + 350) / 570).floor();

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
                    key: _buttonMath3[index],
                    onTap: () async {
                      (lesson.isPublished == false)
                          ? RoadWidget().showUndefinedDialog(context)
                          : (lesson.videoWatched != true)
                          ? RoadWidget().showWatchVideoDialog(context)
                          : (lesson.group1Completed &&
                          lesson.group2Completed)
                          ? await RoadWidget()
                          .math1(context, index,
                          _buttonMath3[index], lesson, 3,
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
                  key: _buttonMath2[index],
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
                      _buttonMath2[index],
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
                  key: _buttonMath1[index],
                  onTap: () async {
                    (lesson.isPublished == false)
                        ? RoadWidget().showUndefinedDialog(context)
                        : (lesson.videoWatched)
                        ? await RoadWidget()
                        .math1(
                      context,
                      index,
                      _buttonMath1[index],
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
                    key: _buttonKeys[index],
                    onTap: () async {
                      (lesson.isPublished == false)
                          ? RoadWidget().showUndefinedDialog(context)
                          : await RoadWidget()
                          .playDialogScreen(
                        context,
                        index,
                        _buttonKeys[index],
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

  Widget _spaceBreaker(String text) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.grey,
            thickness: 1,
            endIndent: 10, // Space between line and text
          ),
        ),
        Center(
          child: SizedBox(
            width: MediaQuery
                .of(context)
                .size
                .width * 0.5,
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.grey,
            thickness: 1,
            indent: 10, // Space between line and text
          ),
        ),
      ],
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
                  key: _buttonMath3[index],
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
                      _buttonMath3[index],
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
                key: _buttonMath2[index],
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
                    _buttonMath2[index],
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
                key: _buttonMath1[index],
                onTap: () async {
                  (lesson.isPublished == false)
                      ? RoadWidget().showUndefinedDialog(context)
                      : (lesson.videoWatched)
                      ? await RoadWidget()
                      .math1(
                    context,
                    index,
                    _buttonMath1[index],
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
                  key: _buttonKeys[index],
                  onTap: () async {
                    (lesson.isPublished == false)
                        ? RoadWidget().showUndefinedDialog(context)
                        : await RoadWidget()
                        .playDialogScreen(
                      context,
                      index,
                      _buttonKeys[index],
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
      backgroundColor: Colors.white,
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
                          scrollIndex * 580,
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
