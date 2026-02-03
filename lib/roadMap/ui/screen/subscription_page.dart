
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
        body: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset('assets/images/subscription.png', width: double.infinity, fit: BoxFit.cover),
                    const SizedBox(height: 20),
                    Container(
                      width: 170,
                      height: 110,
                      decoration: BoxDecoration(
                        image: DecorationImage(image: AssetImage('assets/images/course.png')),
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
                        return Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Text(
                              //   state.subscriptionName.isNotEmpty
                              //       ? state.subscriptionName
                              //       : 'Курс на месяц',
                              //   textAlign: TextAlign.center,
                              //   style: const TextStyle(
                              //     fontWeight: FontWeight.w800,
                              //     fontSize: 20,
                              //     color: Colors.black,
                              //   ),
                              // ),
                              // Text(
                              //   'Барлық сабақтарға доступ алыңыз',
                              //   textAlign: TextAlign.center,
                              //   style: const TextStyle(
                              //     color: Colors.black54,
                              //     fontWeight: FontWeight.w500,
                              //   ),
                              // ),
                              SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Курс бағасы", style: TextStyles.semibold(AppColors.black, fontSize: 17),),
                                      Text(state.currentPrice, style: TextStyles.bold(AppColors.primaryBlue, fontSize: 44),),
                                    ],
                                  ),
                                  SizedBox(width: 24),
                                  Container(
                                    width: 1,
                                    height: 90,
                                    color: Colors.black,
                                  ),
                                  SizedBox(width: 24),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Науқан", style: TextStyles.semibold(AppColors.black, fontSize: 17),),
                                      Text("10%", style: TextStyles.bold(AppColors.primaryBlue, fontSize: 44),),
                                      Text("Скидка", style: TextStyles.semibold(AppColors.black, fontSize: 17),),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 24),
                              if (state.isPurchasing)
                                Center(
                                  child: LoadingAnimationWidget.progressiveDots(
                                    color: GeneralUtil.mainColor,
                                    size: 100,
                                  ),
                                )
                              else
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: AppButton(
                                  text: state.currentPrice.isNotEmpty
                                      ? 'Сатып алу'
                                      : 'Жаңарту',
                                  onPressed: () {
                                    context.read<SubscriptionBloc>().add(
                                          const SubscriptionEvent.purchaseSubscription(),
                                        );
                                  },
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
      ),
    );
  }
}
