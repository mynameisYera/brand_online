// ignore_for_file: unused_element

import 'package:brand_online/core/app_colors.dart';
import 'package:brand_online/core/text_styles.dart';
import 'package:brand_online/core/widgets/app_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_svg/svg.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:brand_online/authorization/entity/RoadMapResponse.dart';
import 'package:brand_online/roadMap/ui/screen/Math1Screen.dart';

class NewResultScreen extends StatefulWidget {
  const NewResultScreen({
    super.key,
    required this.score,
    required this.percentage,
    required this.strike,
    required this.temporaryBalance,
    required this.factory,
    required this.money,
    required this.isCash,
    required this.taskCashback,
    required this.totalCashback,
    this.cashbackActive = false,
    this.stage = 4,
    this.onClose, required this.lesson,
  });

  final int score,
      percentage,
      strike,
      temporaryBalance,
      money,
      taskCashback,
      totalCashback;
  final bool isCash, cashbackActive;
  final double factory;
  final int stage;
  final VoidCallback? onClose;
  final Lesson lesson;

  @override
  State<NewResultScreen> createState() => _NewResultScreenState();
}

class _NewResultScreenState extends State<NewResultScreen> {
  static const int _maxStages = 3;
  final _noScreenshot = NoScreenshot.instance;

  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> _playSuccessSound() async {
    await _audioPlayer.play(AssetSource('sounds/success1.mp3'));
  }

  void enableScreenshot() async {
    bool result = await _noScreenshot.screenshotOn();
    debugPrint('Enable Screenshot: $result');
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), _playSuccessSound);
  }

  @override
  Widget build(BuildContext context) {
    final t = _themes[widget.stage.clamp(1, 3)]!;

    ((widget.factory.isFinite ? widget.factory : 1.0) * 60)
        .clamp(40, 120);

    final bool showCashCol = widget.cashbackActive || widget.isCash;

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 24,),
                  onPressed: () { 
                    enableScreenshot();
                    Navigator.of(context).pop();
                  }
                ),
              ],
            ),
            Text(
              "${widget.stage}",
              style: TextStyles.bold(
                AppColors.white,
                fontSize: 94,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Text(
                widget.stage == 1
                    ? "Сіз бірінші деңгейді\nсәтті аяқтадыңыз.\nЕкінші деңгей ашылды."
                    : widget.stage == 2
                    ? "Сіз екінші деңгейді\nсәтті аяқтадыңыз.\nЕкінші деңгей ашылды."
                    : widget.stage == 3 ? "Сіз барлық деңгейді\nсәтті аяқтадыңыз.\nЖарайсыз!" 
                    : "Сіз қайталау сұрақтарын сәтті аяқтадыңыз!",
                style: TextStyles.bold(
                  AppColors.white,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 30,),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                children: List.generate(_maxStages, (i) {
                  final filled = i < widget.stage;
                  return Expanded(
                    child: Container(
                      height: 10,
                      margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                      decoration: BoxDecoration(
                        color: filled ? Colors.white : Colors.white30,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),
            Text("ЖАРАЙСЫҢ!", style: TextStyles.bold(AppColors.white, fontSize: 24),),
            SizedBox(height: 40,),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 32),
                child: Column(
                  children: [
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          height: 140,
                          padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 21.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.grey, width: 1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                padding: EdgeInsets.all(10),
                                child: SvgPicture.asset('assets/icons/star.svg'),
                              ),
                              const SizedBox(height: 5),
                              Text('${widget.score}', style: TextStyles.bold(AppColors.black)),
                              Text('ұпай', style: TextStyles.regular(AppColors.black, fontSize: 10)),
                            ],
                          ),
                        ),
                        Container(
                          height: 140,
                          padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 21.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.grey, width: 1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.trueGreen.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                padding: EdgeInsets.all(10),
                                child: SvgPicture.asset('assets/icons/increase.svg'),
                              ),
                              const SizedBox(height: 5),
                              Text('${widget.percentage}%', style: TextStyles.bold(AppColors.black)),
                              Text('сұрақ', style: TextStyles.regular(AppColors.black, fontSize: 10)),
                            ],
                          ),
                        ),
                        if (showCashCol)
                          Container(
                          height: 140,
                          padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 21.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.grey, width: 1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.yellow.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                padding: EdgeInsets.all(10),
                                child: SvgPicture.asset('assets/icons/repeat.svg'),
                              ),
                              const SizedBox(height: 5),
                              Text(widget.isCash
                                ? 'x${widget.factory.toStringAsFixed(0)}'
                                : '${widget.totalCashback}', style: TextStyles.bold(AppColors.black, fontSize: 20)),
                              Text(widget.isCash ? 'еселік' : 'кэшбек', style: TextStyles.regular(AppColors.black, fontSize: 10)),
                            ],
                          ),
                        ) ,
                              
                      ],
                    ),
                    Spacer(),
                    
                    widget.stage != 3 ? AppButton(
                      text: "Жалғастыру",
                      onPressed: () async {
                          enableScreenshot();
                          
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Math1Screen(
                                  initialScrollOffset: 20,
                                  lessonId: widget.lesson.lessonId,
                                  groupId: widget.stage+1,
                                  cashbackActive: widget.lesson.cashbackActive,
                                  isCash: false,
                                  lesson: widget.lesson,
                                ),
                              ),
                            );
                        },
                    ) : SizedBox()
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricBarConstrained({
    required String topText,
    required String label,
    required Color barColor,
    required double barHeight,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          topText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textScaler: const TextScaler.linear(1.0),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: barColor,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          width: 44,
          height: barHeight,
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.fade,
          textScaler: const TextScaler.linear(1.0),
          style: const TextStyle(fontSize: 20, color: Colors.black54),
        ),
      ],
    );
  }

  Future<void> _showStrikeDialog(BuildContext ctx, int strike) async {
    showDialog(
      context: ctx,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "ОТТАЙ ЖАНУДАСЫҢ!",
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 30),
                Image.asset('assets/images/fire1.png',
                    width: 100, height: 100),
                const SizedBox(height: 30),
                Text(
                  "$strike күн",
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "қатарынан оқып келесің!",
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      enableScreenshot();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "КЕРЕМЕТ!",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 50,)
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showCashbackDialog(BuildContext ctx) async {
    showDialog(
      context: ctx,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "ЖАРАЙСЫҢ!",
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                // const SizedBox(height: 30),
                // Image.asset('assets/images/brs4.png',
                //     width: 100, height: 100),
                const SizedBox(height: 30),
                Text(
                  "${widget.temporaryBalance} x ${widget.factory} ",
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "${widget.money}",
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "апталық кэшбек",
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 16,
                  ),
                ),
                // const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      enableScreenshot();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "КЕРЕМЕТ!",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ResultTheme {
  final Color bg, accent, badgeBg, badgeBorder, cta, bar1, bar2, bar3;

  const _ResultTheme({
    required this.bg,
    required this.accent,
    required this.badgeBg,
    required this.badgeBorder,
    required this.cta,
    required this.bar1,
    required this.bar2,
    required this.bar3,
  });
}

final _themes = <int, _ResultTheme>{
  1: _ResultTheme(
    bg: AppColors.primaryBlue,
    accent: Color(0xFF00E676),
    badgeBg: Color(0x332C5DE5),
    badgeBorder: Color(0x55FFFFFF),
    cta: Color(0xFF1565C0),
    bar1: Color(0xFF8E24AA),
    bar2: Color(0xFF00C853),
    bar3: Color(0xFFFF7043),
  ),
  2: _ResultTheme(
    bg: AppColors.yellow,
    accent: Color(0xFF2EE6A4),
    badgeBg: Color(0x33FFAB91),
    badgeBorder: Color(0x55FFFFFF),
    cta: Color(0xFFEF6C00),
    bar1: Color(0xFF7E57C2),
    bar2: Color(0xFF00C853),
    bar3: Color(0xFFFF8A65),
  ),
  3: _ResultTheme(
    bg: Color(0xffFF6700),
    accent: Color(0xFF00C853),
    badgeBg: Color(0x33FFE082),
    badgeBorder: Color(0x55FFFFFF),
    cta: Color(0xFFF9A825),
    bar1: Color(0xFF7E57C2),
    bar2: Color(0xFF00C853),
    bar3: Color(0xFFFF7043),
  ),
};
