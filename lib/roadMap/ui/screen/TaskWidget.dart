import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:brand_online/authorization/entity/RoadMapResponse.dart';
import 'package:brand_online/roadMap/service/task_service.dart';
import 'package:brand_online/roadMap/ui/screen/NewResultScreen.dart';
import 'package:brand_online/roadMap/ui/screen/ResultScreen.dart';
import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:just_audio/just_audio.dart' as ja;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:dio/dio.dart';
import 'package:brand_online/roadMap/ui/widget/error_occured_bottom_widget.dart';
import '../../entity/ProfileController.dart';
import 'dart:async';
import '../../entity/TaskEntity.dart';
import '../widget/anagram_input.dart';
import '../widget/anagram_segments_input.dart';
import 'RoadMap.dart';
import 'YoutubeUrlScreen.dart';

class TaskWidget extends StatefulWidget {
  final Task task;
  final bool isRepeat;
  final Profile? profile;
  final bool isLast;
  final VoidCallback onNext;
  final void Function(Task task)? onAnswerIncorrect;
  final bool hintShow;
  final bool isCashbackActive = false;
  final bool isCash;
  final bool cashbackActive;
  final GlobalKey? actionButtonKey;
  final VoidCallback? onCorrect;
  final bool dailyReview;
  final Lesson lesson;
  final bool dailySubjectMode;
  final Future<void> Function(
    int score,
    int percentage,
    int strike,
    int temporaryBalance,
    double factory,
    int money,
    bool isCash,
    int taskCashback,
    int totalCashback,
  )? customShowResultScreen;

  const TaskWidget({
    super.key,
    required this.task,
    required this.isRepeat,
    required this.onNext,
    required this.isLast,
    this.profile,
    this.onAnswerIncorrect,
    this.dailyReview = false,
    required this.hintShow,
    required this.isCash,
    required this.cashbackActive,
    required this.actionButtonKey,
    required this.onCorrect, 
    required this.lesson,
    this.dailySubjectMode = false,
    this.customShowResultScreen,
  });

  @override
  State<TaskWidget> createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget>
    with SingleTickerProviderStateMixin {

  final _anagramCtrl = AnagramSegmentsController();
  // ---- общие состояния ----
  int? selectedChoice;
  bool showCashbackBanner = false;
  int cashbackAmount = 0;
  int? selectedLeftIndex;
  int? selectedRightIndex;
  String userAnswer = "";
  List<Map<String, int>> selectedPairs = [];
  List<Color> pairColors = [];
  Color buttonColor = Colors.blue;
  String buttonText = "ТЕКСЕРУ";
  final ap.AudioPlayer _iosAudioPlayer = ap.AudioPlayer();
  ja.AudioPlayer? _androidAudioPlayer;
  bool usedHelp = false;

  // Matching
  List<Map<String, int>> selectedPairsWithIds = [];

  // Anagram
  // ignore: unused_field
  final _anagramController = AnagramController();

  // animations & submit
  late AnimationController _shakeController;
  late Animation<double> _offsetAnimation;
  bool isSubmitting = false;
  CancelToken? _inFlightCancel;
  final _noScreenshot = NoScreenshot.instance;


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
    buttonColor = (widget.isRepeat) ? Colors.orange : Colors.blue;
    _generateColors();
    disableScreenshot();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _offsetAnimation = Tween<double>(begin: 0, end: 12)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);

    if (Platform.isAndroid) {
      _androidAudioPlayer = ja.AudioPlayer();
    }
  }

  @override
  void dispose() {
    _inFlightCancel?.cancel('dispose');
    _iosAudioPlayer.dispose();
    _androidAudioPlayer?.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  final List<Color> colors = const [
    Color.fromRGBO(75, 167, 255, 1.0),
    Color.fromRGBO(141, 223, 84, 1.0),
    Color.fromRGBO(211, 157, 255, 1.0),
    Color.fromRGBO(255, 217, 66, 1.0),
    Color.fromRGBO(255, 130, 85, 1.0),
  ];
  void _generateColors() {
    final totalItems = widget.task.matchingPairs?.leftItems.length ?? 0;
    pairColors = List.generate(totalItems, (index) => colors[index % colors.length]);
  }

  // --- small helpers ---
  Future<void> _playErrorSound() async =>
      _playSound('sounds/wrong-answer2.mp3');
  Future<void> _playSuccessSound() async =>
      _playSound('sounds/success.mp3');

  Future<void> _playSound(String assetPath) async {
    if (Platform.isIOS) {
      await _iosAudioPlayer.play(ap.AssetSource(assetPath));
      return;
    }
    if (Platform.isAndroid && _androidAudioPlayer != null) {
      try {
        await _androidAudioPlayer!.setAsset('assets/$assetPath');
        await _androidAudioPlayer!.seek(Duration.zero);
        await _androidAudioPlayer!.play();
      } catch (e, stackTrace) {
        debugPrint('Failed to play $assetPath on Android: $e\n$stackTrace');
      }
    }
  }

  void _onErrorUI(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
    _shakeController.forward(from: 0);
    setState(() {
      isSubmitting = false;
      buttonText = 'ТЕКСЕРУ';
      buttonColor = (widget.isRepeat) ? Colors.orange : Colors.blue;
    });
    enableScreenshot();
  }

  Future<void> _submitGuard(Future<void> Function(CancelToken ct) body) async {
    if (!mounted) return;
    setState(() => isSubmitting = true);

    _inFlightCancel?.cancel('new_request');
    _inFlightCancel = CancelToken();

    final watchdog = Future.delayed(const Duration(seconds: 25))
        .then((_) => throw TimeoutException('UI watchdog'));

    try {
      await Future.any([body(_inFlightCancel!), watchdog]);
    } on TimeoutException {
      // _onErrorUI('Уақыт аяқталды. Қайта көріңіз.');
    } on DioException catch (_) {
      _onErrorUI('Интернетке қосылу әлсіз. Тағы да көріңіз.');
    } catch (_) {
      _onErrorUI('Белгісіз қате. Тағы да көріңіз.');
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  Future<void> _handleAnswerUI(int cashback, bool answer) async {
    if (answer) {
      await _playSuccessSound();
    } else {
      await _playErrorSound();
    }

    if (widget.cashbackActive && cashback > 0) {
      setState(() {
        cashbackAmount = cashback;
        showCashbackBanner = true;
      });
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => showCashbackBanner = false);
    }

    if (!mounted) return;
    setState(() {
      buttonColor = answer ? Colors.green : Colors.red;
      isSubmitting = false;
      buttonText = 'ЖАЛҒАСТЫРУ';
    });

    if (answer == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onCorrect?.call();
      });
    }
  }

  // ===================================================================

  @override
  Widget build(BuildContext context) {
    final disabled = (buttonText == 'ЖАЛҒАСТЫРУ' || isSubmitting);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Html(
                    data: widget.task.content,
                    shrinkWrap: true,
                    style: {"*": Style(fontSize: FontSize(18))},
                    extensions: [_mathExtension()],
                  ),
                ),
                const SizedBox(height: 10),
                const Divider(thickness: 1, color: Colors.black),
                const SizedBox(height: 10),

                if (widget.task.taskType == "fill-in-the-blank")
                  _buildFillInTheBlank(disabled),

                if (widget.task.taskType == "multiple-choice")
                  _buildMultipleChoice(disabled),

                if (widget.task.taskType == "matching-pairs")
                  _buildMatchingPairs(disabled),

                if (widget.task.taskType == "anagram")
                  AnagramSegmentsInput(
                    segments: widget.task.anagramSegments,
                    requiredCount: widget.task.anagramRequiredCount ?? widget.task.anagramSegments.length,
                    disabled: (buttonText == 'ЖАЛҒАСТЫРУ' || isSubmitting),
                    isRepeat: widget.isRepeat,
                    controller: _anagramCtrl,
                  ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        // bottom button
        Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 20),
          child: Column(
            children: [
              if (showCashbackBanner)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text("+$cashbackAmount ₸",
                      style: const TextStyle(
                          color: Colors.green,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                ),
              
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 57,
                child: AnimatedBuilder(
                  animation: _shakeController,
                  builder: (context, child) =>
                      Transform.translate(offset: Offset(_offsetAnimation.value, 0), child: child),
                  child: isSubmitting
                      ? Container(
                    decoration: BoxDecoration(color: buttonColor, borderRadius: BorderRadius.circular(20)),
                    alignment: Alignment.center,
                    child: LoadingAnimationWidget.progressiveDots(color: Colors.white, size: 40),
                  )
                      : ElevatedButton(
                    key: widget.actionButtonKey,
                    onPressed: _onMainButtonPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text(
                      buttonText,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  builder: (context) => ErrorOccuredBottomWidget(
                    taskId: widget.task.id.toString(),
                  ),
                ),

                child: Text("Қате байқадыңыз ба?", style: TextStyle(color: Colors.blue ,decoration: TextDecoration.underline, decorationColor: Colors.blue),),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),

        // hints
        if (widget.hintShow) _buildHints() else const SizedBox.shrink(),
      ],
    );
  }

  // -------------------- BUTTON --------------------
  Future<void> _onMainButtonPressed() async {
    if (buttonText == 'ЖАЛҒАСТЫРУ') {
      widget.onNext();
      setState(() {
        buttonText = 'ТЕКСЕРУ';
        buttonColor = (widget.isRepeat) ? Colors.orange : Colors.blue;
        usedHelp = false;
        userAnswer = "";
        selectedChoice = null;
        selectedPairs = [];
        selectedPairsWithIds = [];
        selectedLeftIndex = null;
        selectedRightIndex = null;
        _anagramCtrl.reset(
          widget.task.anagramSegments,
          widget.task.anagramRequiredCount ?? widget.task.anagramSegments.length,
        );
      });
      enableScreenshot();
      return;
    }

    // ====== FILL-IN-THE-BLANK ======
    if (widget.task.taskType == "fill-in-the-blank") {
      if (userAnswer.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Жауап жазыңыз")));
        return;
      }
      FocusManager.instance.primaryFocus?.unfocus();

      await _submitGuard((ct) async {
        await TaskService().submitFillAnswer(
          lessonId: widget.task.id,
          isLast: widget.isLast,
          isRepeat: widget.isRepeat,
          usedHelp: usedHelp,
          state: widget.task.state,
          dailyReview: widget.dailyReview,
          dailySubjectMode: widget.dailySubjectMode,
          answer: userAnswer,
          isCash: widget.isCash,
          cancelToken: ct,
          updateMultiplier: (m) { setState(() { widget.profile?.multiplier = m; ProfileController.updateMultiplier(m); }); },
          updateTask: (t) { setState(() { widget.onAnswerIncorrect?.call(t); }); },
          onNext: _handleNext,
          onError: _onErrorUI,
          showAnswer: (c, a) async => _handleAnswerUI(c, a),
          showResultScreen: widget.customShowResultScreen ?? _showResultScreenAndExit,
        );
      });
      return;
    }

    // ====== MULTIPLE-CHOICE ======
    if (widget.task.taskType == "multiple-choice") {
      if (selectedChoice == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Вариант таңдаңыз")));
        return;
      }

      await _submitGuard((ct) async {
        await TaskService().submitMultipleChoice(
          lessonId: widget.task.id,
          isLast: widget.isLast,
          isRepeat: widget.isRepeat,
          usedHelp: usedHelp,
          isCash: widget.isCash,
          state: widget.task.state,
          dailyReview: widget.dailyReview,
          dailySubjectMode: widget.dailySubjectMode,
          selectedChoice: selectedChoice,
          cancelToken: ct,
          updateMultiplier: (m) { setState(() { widget.profile?.multiplier = m; ProfileController.updateMultiplier(m); }); },
          updateTask: (t) { setState(() { widget.onAnswerIncorrect?.call(t); }); },
          onNext: _handleNext,
          onError: _onErrorUI,
          showAnswer: (c, a) async => _handleAnswerUI(c, a),
          showResultScreen: widget.customShowResultScreen ?? _showResultScreenAndExit,
        );
      });
      return;
    }

    // ====== MATCHING-PAIRS ======
    if (widget.task.taskType == "matching-pairs") {
      final totalPairs = widget.task.matchingPairs?.leftItems.length ?? 0;
      if (selectedPairsWithIds.length < totalPairs) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Барлық жұпты таңдаңыз")));
        return;
      }

      await _submitGuard((ct) async {
        await TaskService().submitMatchingPairs(
          lessonId: widget.task.id,
          isLast: widget.isLast,
          isRepeat: widget.isRepeat,
          state: widget.task.state,
          usedHelp: usedHelp,
          dailyReview: widget.dailyReview,
          dailySubjectMode: widget.dailySubjectMode,
          isCash: widget.isCash,
          matches: selectedPairsWithIds,
          cancelToken: ct,
          updateMultiplier: (m) { setState(() { widget.profile?.multiplier = m; ProfileController.updateMultiplier(m); }); },
          updateTask: (t) { setState(() { widget.onAnswerIncorrect?.call(t); }); },
          onNext: _handleNext,
          onError: _onErrorUI,
          showAnswer: (c, a) async => _handleAnswerUI(c, a),
          showResultScreen: widget.customShowResultScreen ?? _showResultScreenAndExit,
        );
      });
      return;
    }

    // ====== ANAGRAM ======
    if (widget.task.taskType == "anagram") {
      final req = widget.task.anagramRequiredCount ?? widget.task.anagramSegments.length;
      if (!_anagramCtrl.isComplete) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Барлық сегментті орналастырыңыз ($req)")),
        );
        return;
      }

      // локальная подсветка до ответа сервера
      _anagramCtrl.checkAndHighlight(widget.task.anagramAnswer);

      final segments = _anagramCtrl.selectedSegments;

      await _submitGuard((ct) async {
        await TaskService().submitAnagram(
          lessonId: widget.task.id,
          segments: segments,
          isLast: widget.isLast,
          isRepeat: widget.isRepeat,
          usedHelp: usedHelp,
          state: widget.task.state,
          dailyReview: widget.dailyReview,
          dailySubjectMode: widget.dailySubjectMode,
          isCash: widget.isCash,
          cancelToken: ct,
          updateMultiplier: (m) {
            setState(() {
              widget.profile?.multiplier = m;
              ProfileController.updateMultiplier(m);
            });
          },
          updateTask: (t) { setState(() { widget.onAnswerIncorrect?.call(t); }); },
          onNext: _handleNext,
          onError: _onErrorUI,
          showAnswer: (c, a) async => _handleAnswerUI(c, a),
          showResultScreen: widget.customShowResultScreen ?? _showResultScreenAndExit,
        );
      });
      return;
    }

  }

  void _handleNext() {/* управляем через showAnswer */}

  Future<void> _showResultScreenAndExit(
      int score, int percentage, int strike, int temporaryBalance,
      double factory, int money, bool isCash, int taskCashback, int totalCashback,
      ) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => (widget.dailyReview || widget.isCash || widget.isRepeat)
          ? ResultScreen(
        score: score,
        percentage: percentage,
        strike: strike,
        temporaryBalance: temporaryBalance,
        factory: factory,
        taskCashback: taskCashback,
        money: money,
        isCash: isCash,
        cashbackActive: widget.cashbackActive,
        totalCashback: totalCashback,
      )
          : NewResultScreen(
        score: score,
        percentage: percentage,
        strike: strike,
        temporaryBalance: temporaryBalance,
        factory: factory,
        taskCashback: taskCashback,
        money: money,
        isCash: isCash,
        cashbackActive: widget.cashbackActive,
        totalCashback: totalCashback,
        stage: widget.task.group,
        lesson: widget.lesson,
      ),
    );
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => RoadMap(selectedIndx: widget.isRepeat ? 1 : 0, state: 0),
      ),
          (route) => false,
    );
  }

  // ================== UI куски (кроме анаграммы) ==================
  Widget _buildFillInTheBlank(bool disabled) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 20),
        enabled: !disabled,
        onChanged: disabled ? null : (v) => setState(() => userAnswer = v),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: (widget.isRepeat) ? Colors.orange : Colors.blue,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMultipleChoice(bool disabled) {
    return Column(
      children: widget.task.choices.map((choice) {
        final selected = selectedChoice == choice.id;
        return GestureDetector(
          onTap: disabled ? null : () {
            setState(() { selectedChoice = choice.id; FocusManager.instance.primaryFocus?.unfocus(); });
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.all(10),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                color: (widget.isRepeat) ? Colors.orange : Colors.blue,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(20),
              color: selected
                  ? ((widget.isRepeat) ? Colors.orange.withOpacity(.2) : Colors.blue.withOpacity(.2))
                  : Colors.white,
            ),
            child: Center(
              child: Html(
                data: choice.content,
                shrinkWrap: true,
                style: {"*": Style(fontSize: FontSize(14))},
                extensions: [_mathExtension2()],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMatchingPairs(bool disabled) {
    final spacingSize = 14.0;
    return Column(
      children: [
        Column(
          children: List.generate(widget.task.matchingPairs!.leftItems.length, (index) {
            final left = widget.task.matchingPairs!.leftItems[index];
            final right = widget.task.matchingPairs!.rightItems[index];

            return Padding(
              padding: EdgeInsets.only(bottom: spacingSize),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: disabled ? null : () => _selectPair(index, true),
                        child: _buildMatchingItem(left.content, _getPairColor(index, true)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: disabled ? null : () => _selectPair(index, false),
                        child: _buildMatchingItem(right.content, _getPairColor(index, false)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: selectedPairsWithIds.isNotEmpty
              ? Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10, right: 16),
              child: ElevatedButton.icon(
                key: const ValueKey('reselect-visible'),
                onPressed: disabled
                    ? null
                    : () {
                  setState(() {
                    selectedPairs.clear();
                    selectedPairsWithIds.clear();
                    selectedLeftIndex = null;
                    selectedRightIndex = null;
                  });
                },
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text("Қайта таңдау"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          )
              : const SizedBox.shrink(key: ValueKey('reselect-hidden')),
        ),
      ],
    );
  }

  Widget _buildMatchingItem(String content, Color color) {
    return Container(
      constraints: const BoxConstraints(minHeight: 60),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Html(
        data: content,
        shrinkWrap: true,
        style: {
          "*": Style(
            fontSize: FontSize(14),
            whiteSpace: WhiteSpace.normal,
            maxLines: 3,
            textAlign: TextAlign.center,
          ),
        },
        extensions: [_mathExtension2()],
      ),
    );
  }


  // hints
  Widget _buildHints() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () async {
                if (widget.task.videoSolutionUrl == null || widget.task.videoSolutionUrl!.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Видео сілтемесі жоқ")),
                  );
                  return;
                }
                final result = await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  isDismissible: false,
                  enableDrag: false,
                  backgroundColor: Colors.transparent,
                  builder: (context) => Container(
                    height: MediaQuery.of(context).size.height * 0.95,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: YoutubeUrlScreen(videoSolutionUrl: widget.task.videoSolutionUrl ?? "", lesson: widget.lesson,),
                  ),
                );
                if (mounted && result == true) setState(() => usedHelp = true);
              },
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orange, width: 2),
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
                ),
                child: const Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [Text('ВИДЕО', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)), SizedBox(width: 6), Icon(Icons.play_circle_fill, color: Colors.orange)],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => usedHelp = true);
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                  builder: (context) => _buildAnswerModal(widget.task),
                );
              },
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orange, width: 2),
                  borderRadius: const BorderRadius.only(topRight: Radius.circular(16), bottomRight: Radius.circular(16)),
                ),
                child: const Center(
                  child: Text('ЖАУАБЫ', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------- math/html helpers ----------
  TagExtension _mathExtension() => TagExtension(
    tagsToExtend: {"span"},
    builder: (ctx) {
      final formula = ctx.innerHtml.replaceAll(r"\(", "").replaceAll(r"\)", "");
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        margin: const EdgeInsets.symmetric(vertical: 2),
        child: Math.tex(formula, mathStyle: MathStyle.text, textStyle: const TextStyle(fontSize: 18, color: Colors.black)),
      );
    },
  );
  TagExtension _mathExtension2() => TagExtension(
    tagsToExtend: {"span"},
    builder: (ctx) {
      final formula = ctx.innerHtml.replaceAll(r"\(", "").replaceAll(r"\)", "");
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        margin: const EdgeInsets.symmetric(vertical: 2),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Math.tex(formula, textStyle: const TextStyle(fontSize: 16)),
        ),
      );
    },
  );

  Widget _buildAnswerModal(Task answer) {
    Widget answerContent;

    if (answer.taskType == "anagram" && answer.anagramAnswer.isNotEmpty) {
      final asText = answer.anagramAnswer.join("  ");
      answerContent = Center(
        child: Text(asText, textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, color: Colors.black87)),
      );
    } else if (answer.choices.isNotEmpty) {
      final correctChoice = answer.choices.firstWhere((c) => c.isCorrect, orElse: () => answer.choices.first);
      answerContent = Center(
        child: Html(data: correctChoice.content, shrinkWrap: true, style: {"*": Style(fontSize: FontSize(14))}, extensions: [_mathExtension2()]),
      );
    } else if (answer.matchingPairs != null &&
        answer.matchingPairs!.leftItems.isNotEmpty &&
        answer.matchingPairs!.rightItems.isNotEmpty) {
      final pairs = answer.matchingPairs!.leftItems.where((l) {
        return answer.matchingPairs!.rightItems.any((r) => r.id == l.id);
      }).map((l) {
        final r = answer.matchingPairs!.rightItems.firstWhere((x) => x.id == l.id);
        final cleanLeft = _stripMathTex(l.content);
        final cleanRight = _stripMathTex(r.content);
        return '"$cleanLeft" :  "$cleanRight"';
      }).toList();

      answerContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: pairs
            .map((p) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Center(child: Html(data: p, shrinkWrap: true, style: {"*": Style(fontSize: FontSize(14))}, extensions: [_mathExtension2()])),
        ))
            .toList(),
      );
    } else {
      answerContent = Text(
        answer.answer?.correctAnswer ?? "Жауап жоқ",
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
        textAlign: TextAlign.center,
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Жауабы:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
            const SizedBox(height: 10),
            answerContent,
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: (widget.isRepeat) ? Colors.orange : Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('ТҮСІНІКТІ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  String _stripMathTex(String html) {
    html = html.replaceAll(r'\"', '"');
    html = html.replaceAllMapped(
      RegExp(r'<[^>]*class="math-tex"[^>]*>\\\((.*?)\\\)</[^>]*>'),
          (m) => m.group(1) ?? '',
    );
    html = html.replaceAll(RegExp(r'<[^>]*>'), '');
    return html.trim();
  }

  // --- matching helpers ---
  void _selectPair(int index, bool isLeft) {
    if (_isAlreadySelected(index, isLeft)) return;
    setState(() {
      if (isLeft) {
        selectedLeftIndex = index;
      } else {
        selectedRightIndex = index;
      }
      if (selectedLeftIndex != null && selectedRightIndex != null) {
        selectedPairs.add({"left": selectedLeftIndex!, "right": selectedRightIndex!});
        final leftItemId = widget.task.matchingPairs!.leftItems[selectedLeftIndex!].id;
        final rightItemId = widget.task.matchingPairs!.rightItems[selectedRightIndex!].id;
        selectedPairsWithIds.add({"left_id": leftItemId, "right_id": rightItemId});
        selectedLeftIndex = null;
        selectedRightIndex = null;
      }
    });
  }
  bool _isAlreadySelected(int index, bool isLeft) =>
      selectedPairs.any((pair) => pair[isLeft ? "left" : "right"] == index);
  Color _getPairColor(int index, bool isLeft) {
    int? pairIndex = selectedPairs.indexWhere((pair) => pair[isLeft ? "left" : "right"] == index);
    if (pairIndex != -1) return pairColors[pairIndex];
    if ((isLeft && selectedLeftIndex == index) || (!isLeft && selectedRightIndex == index)) {
      return Colors.blue.withOpacity(0.5);
    }
    return Colors.white;
  }
}
