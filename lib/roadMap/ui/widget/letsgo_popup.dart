import 'package:brand_online/core/app_colors.dart';
import 'package:brand_online/core/text_styles.dart';
import 'package:brand_online/core/widgets/app_button_widget.dart';
import 'package:flutter/material.dart';

class LetsgoPopup extends StatelessWidget {
  const LetsgoPopup({super.key, this.title = 'Кеттік!', this.subtitle = 'Кеттік!', this.onContinue, this.onReportTap});
  final String title;
  final String subtitle;
  final VoidCallback? onContinue;
  final VoidCallback? onReportTap;

  @override
  Widget build(BuildContext context) {
    final onBackTap = onReportTap ?? () => Navigator.pop(context);

    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: const BoxDecoration(
          color: AppColors.primaryBlue,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Stack(
          children: [
            
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyles.bold(AppColors.white, fontSize: 18),
                ),
                const SizedBox(height: 12),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyles.semibold(AppColors.white, fontSize: 14),
                ),
                const SizedBox(height: 24),
                AppButton(
                  text: 'Кеттік!',
                  variant: AppButtonVariant.outlined,
                  color: AppButtonColor.blue,
                  height: 64,
                  onPressed: onContinue,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: onBackTap,
                  child: Text(
                    'Артқа',
                    style: TextStyles.regular(AppColors.white, fontSize: 18),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ],
        ),
      );
  }
}