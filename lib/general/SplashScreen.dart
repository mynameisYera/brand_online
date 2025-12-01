import 'dart:async';
import 'package:flutter/material.dart';
import 'package:brand_online/roadMap/ui/screen/RoadMap.dart';

class SplashScreen extends StatefulWidget {
  final bool navigator;

  const SplashScreen({super.key,
  required this.navigator});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 1), () {
      if (widget.navigator) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RoadMap(selectedIndx: 0, state: 0)),
        );
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // или другой фон
      body: Center(
        child: Image.asset(
          'assets/images/restartLogo.png',
          width: 200,
          height: 200,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}