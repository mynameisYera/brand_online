import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../general/GeneralUtil.dart';

class NoSubscriptionPage extends StatelessWidget {
  final String title;
  final String message;
  final String buttonMessage;
  final String whatsappUrl;

  const NoSubscriptionPage({
    super.key,
    required this.title,
    required this.message,
    required this.buttonMessage,
    required this.whatsappUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: GeneralUtil.greenColor)),
                const SizedBox(height: 20),
                Image.asset('assets/images/baryss.png', width: 300),
                const SizedBox(height: 20),
                Text(
                  message,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
                      await launchUrl(Uri.parse(whatsappUrl), mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(FontAwesomeIcons.whatsapp),
                  label: Text(buttonMessage),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GeneralUtil.greenColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}