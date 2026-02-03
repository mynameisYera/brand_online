import 'package:brand_online/core/app_colors.dart';
import 'package:brand_online/core/text_styles.dart';
import 'package:brand_online/core/widgets/app_button_widget.dart';
import 'package:brand_online/general/GeneralUtil.dart';
import 'package:flutter/material.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'RoadMap.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ResultScreen extends StatefulWidget {
  final int score;
  final int percentage;
  final int strike;
  final int temporaryBalance;
  final int money;
  final double factory;
  final bool isCash;
  final bool cashbackActive;
  final int taskCashback;
  final int totalCashback;

  const ResultScreen({
    super.key,
    required this.score,
    required this.percentage,
    required this.strike,
    required this.temporaryBalance,
    required this.factory,
    required this.money,
    required this.isCash,
    required this.cashbackActive,
    required this.taskCashback,
    required this.totalCashback,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final _noScreenshot = NoScreenshot.instance;

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
    Future.delayed(const Duration(seconds: 1), () {
      _playSuccessSound();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double questionProgress = (widget.percentage / 100).clamp(0.0, 1.0);
    Color backgroundColor = AppColors.white;
    if (questionProgress >= 0.7) {
      backgroundColor = AppColors.primaryBlue;
    }else if (questionProgress >= 0.5 && questionProgress < 0.7) {
      backgroundColor = AppColors.yellow;
    }else if (questionProgress < 0.5) {
      backgroundColor = Color(0xffFF6700);
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildAccuracyCard(questionProgress),
                            if (questionProgress >= 0.7 && questionProgress <= 1)
                            Text(
                              "ЖАРАЙСЫҢ!",
                              style: TextStyles.bold(
                                AppColors.white,
                                fontSize: 22,
                              ),
                            ),
                            if (questionProgress >= 0.5 && questionProgress < 0.7)
                            Text(
                              "ТАЛПЫН!",
                              style: TextStyles.bold(
                                AppColors.white,
                                fontSize: 22,
                              ),
                            ),
                            if (questionProgress < 0.5)
                            Text(
                              "Қиын болды!",
                              style: TextStyles.bold(
                                AppColors.white,
                                fontSize: 22,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        children: [
                          Spacer(),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            child: AppButton(
                            text: "Керемет!", 
                              onPressed: () {
                                  enableScreenshot();
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          RoadMap(selectedIndx: 1, state: 0),
                                    ),
                                    (Route<dynamic> route) => false,
                                  );
                                },
                            ),
                          )
                        ],
                      )
                    )
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccuracyCard(double progress) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return SizedBox(
                width: 190,
                height: 190,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 190,
                      height: 190,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(
                      width: 180,
                      height: 180,
                      child: LoadingAnimationWidget.progressiveDots(
                        color: GeneralUtil.mainColor,
                        size: 100,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "${(value * 100).round()}%",
                          style: TextStyles.bold(
                            AppColors.white,
                            fontSize: 32,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
