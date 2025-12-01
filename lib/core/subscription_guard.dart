import 'package:flutter/material.dart';
import 'package:brand_online/core/subscription_service.dart';
import 'package:brand_online/roadMap/ui/screen/subscription_page.dart';

class SubscriptionGuard extends StatelessWidget {
  final Widget child;
  final String whatsappUrl;
  final bool requireSubscription;

  const SubscriptionGuard({
    super.key,
    required this.child,
    required this.whatsappUrl,
    this.requireSubscription = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!requireSubscription) {
      return child;
    }

    final subscriptionService = SubscriptionService();
    
    if (subscriptionService.hasActiveSubscription) {
      return child;
    } else {
      return SubscriptionPage();
    }
  }
}

class SubscriptionContent extends StatelessWidget {
  final Widget premiumChild;
  final Widget freeChild;
  final bool showPremium;

  const SubscriptionContent({
    super.key,
    required this.premiumChild,
    required this.freeChild,
    this.showPremium = true,
  });

  @override
  Widget build(BuildContext context) {
    final subscriptionService = SubscriptionService();
    final hasSubscription = subscriptionService.hasActiveSubscription;
    
    if (hasSubscription && showPremium) {
      return premiumChild;
    } else {
      return freeChild;
    }
  }
}

// Виджет для кнопки подписки
class SubscribeButton extends StatelessWidget {
  final String whatsappUrl;
  final String text;
  final Color? backgroundColor;
  final Color? textColor;

  const SubscribeButton({
    super.key,
    required this.whatsappUrl,
    this.text = 'Подписаться',
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SubscriptionPage(),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? Colors.black,
        foregroundColor: textColor ?? Colors.white,
      ),
      child: Text(text),
    );
  }
}
