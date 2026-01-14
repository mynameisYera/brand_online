import 'package:flutter/material.dart';
import 'package:brand_online/core/app_colors.dart';
import 'package:brand_online/core/text_styles.dart';

class CorrectAnswerPopup extends StatelessWidget {
  const CorrectAnswerPopup({
    super.key,
    this.answer = '',
    this.title = 'Дұрыс Жауап!',
    this.subtitle = 'Қате таптыңыз ба?',
    this.avatarAsset = 'assets/images/brandon.png',
    this.onContinue,
    this.onReportTap,
  });

  final String answer;
  final String title;
  final String subtitle;
  final String avatarAsset;
  final VoidCallback? onContinue;
  final VoidCallback? onReportTap;
  @override
  Widget build(BuildContext context) {
    final handleContinue = onContinue ?? () => Navigator.of(context).pop();
    return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.trueGreen,
            borderRadius: BorderRadius.circular(19),
          ),
          child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(image: AssetImage("assets/images/correct.png"))
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        title,
                        style: TextStyles.bold(AppColors.white, fontSize: 22),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextButton(
                      onPressed: handleContinue,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'ЖАЛҒАСТЫРУ',
                        style: TextStyles.bold(AppColors.trueGreen, fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: onReportTap,
                    child: Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyles.medium(AppColors.white, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
        );
  }
}