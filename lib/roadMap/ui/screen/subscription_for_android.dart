import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:brand_online/roadMap/ui/widget/custom_button_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionForAndroid extends StatelessWidget {
  final String whatsappUrl;
  const SubscriptionForAndroid({super.key, required this.whatsappUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Colors.black,
          title: const Text(
            'Жазылым',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              width: double.infinity,
              child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 150,
                      ),
                      Image.asset(
                        'assets/images/admbarys.png',
                        width: 120,
                        height: 120,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Курс сатып алу үшін WhatsApp-та менеджерлерге жазыңыз.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          height: 1.4,
                        ),
                      ),
                      
                      const SizedBox(height: 28),
                      CustomButtonWidget(
                        color: Colors.green,
                        text: "WhatsApp",
                        onTap: () => _openWhatsApp(context),
                      ),
                    ],
                  ),
            ),
          ),
        ));
  }

  Future<void> _openWhatsApp(BuildContext context) async {
    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(Uri.parse(whatsappUrl), mode: LaunchMode.externalApplication);
    }else{
      _showSnackBar(context, "Кейінірек қайталап көріңіз");
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}