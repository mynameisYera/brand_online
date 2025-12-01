import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:brand_online/roadMap/ui/widget/custom_button_widget.dart';
import 'package:brand_online/pursache/subscription_bloc.dart';
import 'package:brand_online/general/SplashScreenWithoutButtons.dart';
import 'package:url_launcher/url_launcher.dart';

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
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          actions: [
            // BlocBuilder<SubscriptionBloc, SubscriptionState>(
            //   builder: (context, state) {
            //     if (state.isLoading) {
            //       return const Padding(
            //         padding: EdgeInsets.all(16.0),
            //         child: SizedBox(
            //           width: 20,
            //           height: 20,
            //           child: CircularProgressIndicator(strokeWidth: 2),
            //         ),
            //       );
            //     }
            //     return IconButton(
            //       icon: const Icon(Icons.restore),
            //       onPressed: () {
            //         context.read<SubscriptionBloc>().add(
            //               const SubscriptionEvent.restorePurchases(),
            //             );
            //       },
            //       tooltip: 'Восстановить покупки',
            //     );
            //   },
            // ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      'Курс сатып алыңыз',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                    ),
                    const SizedBox(height: 16),
                    BlocConsumer<SubscriptionBloc, SubscriptionState>(
                      listener: (context, state) {
                        if (state.error != null && state.error!.isNotEmpty) {
                          final bool isSuccess = state.error!.contains('успешно');
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   SnackBar(
                          //     content: Text(state.error!),
                          //     backgroundColor: isSuccess ? Colors.green : Colors.red,
                          //     duration: const Duration(seconds: 2),
                          //   ),
                          // );

                          if (isSuccess) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SplashScreenWithoutButtons(),
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
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFEAEAEA)),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x11000000),
                                blurRadius: 16,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Image.asset(
                                'assets/images/admbarys.png',
                                width: 80,
                                height: 80,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                state.subscriptionName.isNotEmpty
                                    ? state.subscriptionName
                                    : 'Курс на месяц',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Барлық сабақтарға доступ алыңыз',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (state.currentPrice.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Text(
                                  state.currentPrice,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 16),
                              const _FeatureRow(text: 'Ағылшын'),
                              const SizedBox(height: 8),
                              const _FeatureRow(text: 'Математика'),
                              const SizedBox(height: 8),
                              const _FeatureRow(text: 'Сандық сипаттама'),
                              const SizedBox(height: 20),
                              if (state.isPurchasing)
                                const Center(
                                  child: CircularProgressIndicator.adaptive(
                                    backgroundColor: Colors.blue,
                                  ),
                                )
                              else
                                CustomButtonWidget(
                                  color: Colors.black,
                                  text: state.currentPrice.isNotEmpty
                                      ? 'Сатып алу ${state.currentPrice.split(' ')[0]}'
                                      : 'Жаңарту',
                                  textColor: Colors.white,
                                  onTap: () {
                                    context.read<SubscriptionBloc>().add(
                                          const SubscriptionEvent.purchaseSubscription(),
                                        );
                                  },
                                ),
                              // CustomButtonWidget(
                              //     color: Colors.black,
                              //     text: Жаңарту,
                              //     textColor: Colors.white,
                              //     onTap: () {
                              //       context.read<SubscriptionBloc>().add(
                              //             const SubscriptionEvent.purchaseSubscription(),
                              //           );
                              //     },
                              //   ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton(
                                    onPressed: () async {
                                      const String privacyUrl = 'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/';
                                      final Uri uri = Uri.parse(privacyUrl);
                                      if (await canLaunchUrl(uri)) {
                                        await launchUrl(uri, mode: LaunchMode.inAppWebView);
                                      } else {
                                        
                                      }
                                    },
                                    child: const Text('Terms of Use (EULA)', style: TextStyle(color: Colors.blue, fontSize: 12, decoration: TextDecoration.underline, decorationColor: Colors.blue)),
                                  ),
                                  SizedBox(width: 10),
                                  TextButton(
                                    onPressed: () {
                                      context.read<SubscriptionBloc>().add(
                                            const SubscriptionEvent.openPrivacyPolicy(),
                                          );
                                    },
                                    child: const Text(
                                      'Privacy Policy',
                                      style: TextStyle(color: Colors.blue, fontSize: 12, decoration: TextDecoration.underline, decorationColor: Colors.blue),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String text;
  const _FeatureRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(Icons.check, color: Colors.green, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

