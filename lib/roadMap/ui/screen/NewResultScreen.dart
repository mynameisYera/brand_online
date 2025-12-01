// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
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

    const double maxScore = 80.0;
    final double scoreHeight = (widget.score / maxScore * 100).clamp(40, 100);
    final double questionHeight =
    (widget.percentage / 100 * 120).clamp(40, 120);
    final double multiplierHeight =
    ((widget.factory.isFinite ? widget.factory : 1.0) * 60)
        .clamp(40, 120);

    final bool showCashCol = widget.cashbackActive || widget.isCash;

    const double _headerHeight = 350;
    const double _headerContentTop = 150;

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: _headerHeight,
              child: Stack(
                children: [
                  Positioned(
                    top: 6,
                    left: 6,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () { 
                        enableScreenshot();
                        Navigator.of(context).pop();
                      }
                    ),
                  ),
                  if (widget.factory >= 2)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.18),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Text(
                          'x${widget.factory.toStringAsFixed(0)}',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  Positioned(
                    top: _headerContentTop,
                    left: 16,
                    right: 16,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: '3/',
                                style: TextStyle(
                                  fontSize: 35,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                        color: Colors.black26, blurRadius: 6)
                                  ],
                                ),
                              ),
                              TextSpan(
                                text: '${widget.stage}',
                                style: const TextStyle(
                                  fontSize: 94,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  height: .9,
                                  shadows: [
                                    Shadow(
                                        color: Colors.black26, blurRadius: 6)
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Text(
                              widget.stage == 1
                                  ? "Сіз бірінші деңгейді\nсәтті аяқтадыңыз.\nЕкінші деңгей ашылды."
                                  : widget.stage == 2
                                  ? "Сіз екінші деңгейді\nаяқтадыңыз. Келесі\n– шешуші деңгей\nашық."
                                  : widget.stage == 3 ? "Сіз барлық деңгейді\nсәтті аяқтадыңыз.\nЖарайсыз!" 
                                  : "Сіз қайталау сұрақтарын сәтті аяқтадыңыз!",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                height: 1.25,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 16,
                    child: Row(
                      children: List.generate(_maxStages, (i) {
                        final filled = i < widget.stage;
                        return Expanded(
                          child: Container(
                            height: 6,
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
                ],
              ),
            ),

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
                    // const SizedBox(height: 6),
                    const Text(
                      "ЖАРАЙСЫҢ!",
                      style:
                      TextStyle(fontSize: 24, fontWeight: FontWeight.w800,),
                    ),
                    // const SizedBox(height: 8),
                    // const SizedBox(height: 22),

                    SizedBox(
                      height: 200,
                      child: LayoutBuilder(
                        builder: (ctx, cons) {
                          const double overhead = 72;
                          final double maxBarH =
                          (cons.maxHeight - overhead)
                              .clamp(0.0, cons.maxHeight);

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _metricBarConstrained(
                                topText: '${widget.score}',
                                label: 'ұпай',
                                barColor: t.bar1,
                                barHeight: scoreHeight.clamp(0, maxBarH),
                              ),
                              _metricBarConstrained(
                                topText: '${widget.percentage}%',
                                label: 'сұрақ',
                                barColor: t.bar2,
                                barHeight: questionHeight.clamp(0, maxBarH),
                              ),
                              if (showCashCol)
                                _metricBarConstrained(
                                  topText: widget.isCash
                                      ? 'x${widget.factory.toStringAsFixed(0)}'
                                      : '${widget.totalCashback}',
                                  label:
                                  widget.isCash ? 'еселік' : 'кэшбек',
                                  barColor: t.bar3,
                                  barHeight:
                                  multiplierHeight.clamp(0, maxBarH),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                    // const Spacer(),
                    // CustomButtonWidget(color: Colors.blue, text: "text", onTap: (){
                    //   Navigator.push(
                    //           context,
                    //           MaterialPageRoute(
                    //             builder: (context) => Math1Screen(
                    //               initialScrollOffset: 20,
                    //               lessonId: widget.lesson.lessonId,
                    //               groupId: widget.stage + 1,
                    //               cashbackActive: widget.lesson.cashbackActive,
                    //               isCash: false,
                    //             ),
                    //           ),
                    //         );
                    // }),

                    // SizedBox(
                    //   width: double.infinity,
                    //   height: 54,
                    //   child: ElevatedButton(
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor: t.cta,
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(16),
                    //       ),
                    //     ),
                    //     onPressed: () async {
                    //       enableScreenshot();
                    //       if (widget.strike > 0) {
                    //         await _showStrikeDialog(context, widget.strike);
                    //       }
                    //       if (widget.isCash == true) {
                    //         await _showCashbackDialog(context);
                    //       }
                    //       if (!context.mounted) return;
                    //       Navigator.pushAndRemoveUntil(
                    //         context,
                    //         MaterialPageRoute(
                    //           builder: (_) =>
                    //           const RoadMap(selectedIndx: 0, state: 0),
                    //         ),
                    //             (_) => false,
                    //       );
                    //     },
                    //     child: const Text(
                    //       "КЕРЕМЕТ!",
                    //       style: TextStyle(
                    //         color: Colors.white,
                    //         fontWeight: FontWeight.w800,
                    //         fontSize: 14,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // SizedBox(height: 5),
                    Spacer(),
                    widget.stage != 3 ? SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: t.cta,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
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
                        child: const Text(
                          "Келесі тестке өту!",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
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
  1: const _ResultTheme(
    bg: Color(0xFF3D8BFF),
    accent: Color(0xFF00E676),
    badgeBg: Color(0x332C5DE5),
    badgeBorder: Color(0x55FFFFFF),
    cta: Color(0xFF1565C0),
    bar1: Color(0xFF8E24AA),
    bar2: Color(0xFF00C853),
    bar3: Color(0xFFFF7043),
  ),
  2: const _ResultTheme(
    bg: Color(0xFFFF7043),
    accent: Color(0xFF2EE6A4),
    badgeBg: Color(0x33FFAB91),
    badgeBorder: Color(0x55FFFFFF),
    cta: Color(0xFFEF6C00),
    bar1: Color(0xFF7E57C2),
    bar2: Color(0xFF00C853),
    bar3: Color(0xFFFF8A65),
  ),
  3: const _ResultTheme(
    bg: Color(0xFFFFC107),
    accent: Color(0xFF00C853),
    badgeBg: Color(0x33FFE082),
    badgeBorder: Color(0x55FFFFFF),
    cta: Color(0xFFF9A825),
    bar1: Color(0xFF7E57C2),
    bar2: Color(0xFF00C853),
    bar3: Color(0xFFFF7043),
  ),
};
