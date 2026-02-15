import 'package:brand_online/core/app_colors.dart';
import 'package:brand_online/core/text_styles.dart';
import 'package:brand_online/core/widgets/app_button_widget.dart';
import 'package:flutter/material.dart';
import '../../roadMap/ui/screen/RoadMap.dart';

class BalanceWithdrawSuccessPage extends StatelessWidget {
  final int amount;

  const BalanceWithdrawSuccessPage({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 40),
            Column(
              children: [
                Text(
                  'Өтінім жіберілді',
                  style: TextStyles.bold(AppColors.primaryBlue, fontSize: 32),
                ),
                const SizedBox(height: 16),
                Image.asset(
                  'assets/images/satti.png',
                  height: 250,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                Text(
                  '$amount ₸',
                  style: TextStyles.bold(AppColors.primaryBlue, fontSize: 64),
                ),
                const SizedBox(height: 4),
                Text(
                  'қарастырылу 3 жұмыс күні ішінде іске асады*',
                  style: TextStyles.semibold(AppColors.primaryBlue, fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: AppButton(
              text: "КЕРЕМЕТ", 
              onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const RoadMap(selectedIndx: 5, state: 0)),
                  ),
            ),
            )
          ],
        ),
      ),
    );
  }
}
