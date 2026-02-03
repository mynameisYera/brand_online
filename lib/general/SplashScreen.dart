import 'dart:async';
import 'package:brand_online/authorization/ui/screen/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:brand_online/roadMap/ui/screen/RoadMap.dart';
import 'package:flutter_svg/svg.dart';

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
      }else{
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: 180,
          height: 180,
          padding: EdgeInsets.all(50),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0082FF), Color(0xFF104CAA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(100),
          ),
          child: SvgPicture.asset('assets/icons/logo_e.svg', width: 50, color: Colors.white),
        ),
      ),
    );
  }
}