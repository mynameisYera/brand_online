
import 'package:brand_online/core/app_colors.dart';
import 'package:brand_online/core/text_styles.dart';
import 'package:brand_online/core/widgets/app_button_widget.dart';
import 'package:brand_online/general/SplashScreen.dart';
import 'package:brand_online/general/GeneralUtil.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:brand_online/pursache/subscription_bloc.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SubscriptionBloc()..add(const SubscriptionEvent.init()),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final bool isDesktop = constraints.maxWidth >= 1024;
            final bool isTablet = constraints.maxWidth >= 700;
            final double maxContentWidth = isDesktop ? 820 : (isTablet ? 700 : double.infinity);
            final double horizontalPadding = isDesktop ? 32 : (isTablet ? 24 : 0);
            final double bannerHeight = isDesktop ? 280 : (isTablet ? 240 : 200);

            return SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(isTablet ? 20 : 0),
                          child: Image.asset(
                            'assets/images/subscription.png',
                            width: double.infinity,
                            height: bannerHeight,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Container(
                            width: isDesktop ? 210 : 170,
                            height: isDesktop ? 130 : 110,
                            decoration: const BoxDecoration(
                              image: DecorationImage(image: AssetImage('assets/images/course.png')),
                            ),
                          ),
                        ),
                        BlocConsumer<SubscriptionBloc, SubscriptionState>(
                          listener: (context, state) {
                            if (state.error != null && state.error!.isNotEmpty) {
                              final bool isSuccess = state.error!.contains('успешно');
                              if (isSuccess) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SplashScreen(navigator: true),
                                  ),
                                  (route) => false,
                                );
                              }

                              context.read<SubscriptionBloc>().add(
                                    const SubscriptionEvent.clearError(),
                                  );
                            }
                          },
                          builder: (context, state) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Курс бағасы",
                                          style: TextStyles.semibold(AppColors.black, fontSize: 17),
                                        ),
                                        Text(
                                          state.currentPrice,
                                          style: TextStyles.bold(AppColors.primaryBlue, fontSize: 44),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 24),
                                    Container(
                                      width: 1,
                                      height: 90,
                                      color: Colors.black,
                                    ),
                                    const SizedBox(width: 24),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Науқан",
                                          style: TextStyles.semibold(AppColors.black, fontSize: 17),
                                        ),
                                        Text(
                                          "10%",
                                          style: TextStyles.bold(AppColors.primaryBlue, fontSize: 44),
                                        ),
                                        Text(
                                          "Скидка",
                                          style: TextStyles.semibold(AppColors.black, fontSize: 17),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                if (state.isPurchasing)
                                  Center(
                                    child: LoadingAnimationWidget.progressiveDots(
                                      color: GeneralUtil.mainColor,
                                      size: 100,
                                    ),
                                  )
                                else
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: isDesktop ? 120 : 16),
                                    child: AppButton(
                                      text: state.currentPrice.isNotEmpty ? 'Сатып алу' : 'Жаңарту',
                                      onPressed: () {
                                        context.read<SubscriptionBloc>().add(
                                              const SubscriptionEvent.purchaseSubscription(),
                                            );
                                      },
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
